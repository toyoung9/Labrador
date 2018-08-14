//
//  LabradorNetworkProvider.m
//  Labrador
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorNetworkProvider.h"
#import "LabradorCache.h"
#import "LabradorDownloader.h"
#import "configure.h"
#import "NSString+Extensions.h"
#import "configure.h"

@interface LabradorNetworkProvider()<LabradorDownloaderDelegate>
{
    NSString *_urlString ;
    NSUInteger _cacheMinSize ;
    LabradorCache *_cache ;
    LabradorDownloader *_dowmloader ;
    NSCondition *_lock ;
    NSOperationQueue *_downloadOperationQueue ;
    NSFileHandle *_dataFileHandle ;
    NSMutableData *_data ;
}
@end
@implementation LabradorNetworkProvider

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString * _Nonnull)urlString
{
    self = [super init];
    if (self) {
        _cacheMinSize = 1024 * 128 ;
        _lock = [[NSCondition alloc] init] ;
        _data = [[NSMutableData alloc] init] ;
        _downloadOperationQueue = [[NSOperationQueue alloc] init] ;
        _downloadOperationQueue.maxConcurrentOperationCount = 1 ;
        _urlString = urlString ;
        _cacheStatus = LabradorCache_Status_Caching ;
        _cache = [[LabradorCache alloc] initWithURLString:_urlString] ;
        _dataFileHandle = [NSFileHandle fileHandleForWritingAtPath:[_urlString cachePath]] ;
        if(_delegate){
            [_delegate cacheStatusChanged:_cacheStatus] ;
        }
        if(_cache.isInitializedCache) {
            [self startNextFragmentDownload] ;
        } else {
            _dowmloader = [[LabradorDownloader alloc] initWithURLString:_urlString start:0 length:LabradorAudioQueueBufferCacheSize] ;
            _dowmloader.delegate = self ;
            [_dowmloader start] ;
        }
    }
    return self;
}

- (void)startNextFragmentDownload {
    NSRange range = [_cache findNextDownloadFragment] ;
    _dowmloader = [[LabradorDownloader alloc] initWithURLString:_urlString start:range.location * 1024 length:range.length * 1024] ;
    _dowmloader.delegate = self ;
    [_dowmloader start] ;
}

#pragma mark - LabradorDataProvider implementation

- (NSUInteger)getBytes:(void *)bytes size:(NSUInteger)size offset:(NSUInteger)offset {
    NSAssert(size <= _cacheMinSize, @"_cacheMinSize must be >= size") ;
    NSUInteger length = 0 ;
    [_lock lock] ;
    if(offset == 0) {
        //read header information
        if(_data.length < size) {
            [_lock wait] ;
        }
        [_data getBytes:bytes range:NSMakeRange(offset, size)] ;
        length = size ;
    } else {
        NSRange range = [_cache findNextCacheFragmentFrom:_dowmloader.startLocation] ;
        if(range.length < _cacheMinSize) {
            [_lock wait] ;
        }
        length = range.length ;
    }
    [_lock unlock] ;
    return length ;
}

- (void)receiveData:(NSData *)data start:(NSUInteger)start{
    
    if(data && data.length > 0) {
        [_lock lock] ;
        [_dataFileHandle seekToFileOffset:start] ;
        [_dataFileHandle writeData:data] ;
        [_cache completedFragment:start / 1024 length:data.length / 1024] ;
        [_data appendData:data] ;
        NSLog(@"-------收到数据: %ld, %ld---(%ld, %ld)", start, data.length, _data.length, _dowmloader.length) ;
        if(_dowmloader.startLocation == 0) {
            // download header information data
            if(_data.length >= _dowmloader.length) {
                [_lock signal] ;
                
            }
        } else {
            NSRange range = [_cache findNextCacheFragmentFrom:_dowmloader.startLocation] ;
            if(range.length >= _cacheMinSize) {
                [_lock signal] ;
            }
        }
       [_lock unlock] ;
    }
}
- (void)receiveContentLength:(NSUInteger)contentLength{
    [_cache initializeLength:contentLength] ;
    [self startNextFragmentDownload] ;
}
- (void)completed {
    NSLog(@"片段下载完成: %ld", _data.length) ;
//    [self startNextFragmentDownload] ;
}

@end
