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
    LabradorDownloader *_downloader ;
    NSCondition *_lock ;
    NSOperationQueue *_downloadOperationQueue ;
    NSFileHandle *_dataWriteHandle ;
    NSFileHandle *_dataReadHandle ;
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
        _downloadOperationQueue = [[NSOperationQueue alloc] init] ;
        _downloadOperationQueue.maxConcurrentOperationCount = 1 ;
        _urlString = urlString ;
        _cacheStatus = LabradorCache_Status_Caching ;
        _cache = [[LabradorCache alloc] initWithURLString:_urlString] ;
        NSString *path = [_urlString cachePath] ;
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:NULL attributes:NULL] ;
        }
        _dataWriteHandle = [NSFileHandle fileHandleForWritingAtPath:path] ;
        _dataReadHandle = [NSFileHandle fileHandleForReadingAtPath:path] ;
        if(_delegate){
            [_delegate cacheStatusChanged:_cacheStatus] ;
        }
        if(_cache.isInitializedCache) {
            [self startNextFragmentDownload] ;
        } else {
            _downloader = [[LabradorDownloader alloc] initWithURLString:_urlString
                                                                  start:0
                                                                 length:LabradorAudioHeaderInputSize
                                                           downloadType:DownloadType_Header] ;
            _downloader.delegate = self ;
            [_downloader start] ;
        }
    }
    return self;
}

- (void)startNextFragmentDownload {
    NSRange range = [_cache findNextDownloadFragment] ;
    if(range.length == 0) return ;
    _downloader = [[LabradorDownloader alloc] initWithURLString:_urlString start:range.location  length:range.length  downloadType:DownloadType_AudioData] ;
    _downloader.delegate = self ;
    [_downloader start] ;
}

#pragma mark - LabradorDataProvider implementation

- (NSUInteger)getBytes:(void *)bytes size:(NSUInteger)size offset:(NSUInteger)offset {
    NSAssert(size <= _cacheMinSize, @"_cacheMinSize must be >= size") ;
    NSUInteger length = 0 ;
    [_lock lock] ;
    if(_downloader.downloadType == DownloadType_Header) {
        //read header information
        NSRange headerRange = [_cache findNextCacheFragmentFrom:0] ;
        if(headerRange.length < size) {
            [_lock wait] ;
        }
        [_dataReadHandle seekToFileOffset:0] ;
        NSData *data = [_dataReadHandle readDataOfLength:size] ;
        [data getBytes:bytes range:NSMakeRange(0, size)] ;
        length = data.length ;
    } else {
        //查找接下来连续缓存区是否满足最小设定
        NSRange range = [_cache findNextCacheFragmentFrom:_downloader.startLocation] ;
        if(range.length < _cacheMinSize && range.length > 0) {
            //不满足,则等待数据下载
            [_lock wait] ;
        }
        //满足后进行数据读取
        [_dataReadHandle seekToFileOffset:offset] ;
        NSData *data = [_dataReadHandle readDataOfLength:size] ;
        [data getBytes:bytes range:NSMakeRange(0, size)] ;
        length = data.length ;
    }
    [_lock unlock] ;
    return length ;
}

- (void)receiveData:(NSData *)data start:(NSUInteger)start{
    //收到以数据
    if(data && data.length > 0) {
        [_lock lock] ;
        [_dataWriteHandle seekToFileOffset:start] ;
        [_dataWriteHandle writeData:data] ;
        //写入映射缓存
        [_cache completedFragment:start length:data.length] ;
        if(_downloader.downloadType == DownloadType_Header) {
            // download header information data
            if([_downloader downloadCompleted]) {
                NSLog(@"头信息下载完成") ;
                [_lock signal] ;
                
            }
        } else {
            NSRange range = [_cache findNextCacheFragmentFrom:_downloader.startLocation] ;
            if(range.length >= _cacheMinSize) {
                [_lock signal] ;
            }
        }
       [_lock unlock] ;
    }
}
- (void)receiveContentLength:(NSUInteger)contentLength{
    //初始化头信息与缓存映射文件信息
    NSLog(@"文件大小: %lu", contentLength) ;
    if(_downloader.downloadType == DownloadType_Header) {
        [_cache initializeLength:contentLength] ;
        [self startNextFragmentDownload] ;
    }
    
}
- (void)completed:(BOOL)isDownloadFullData {
    NSLog(@"片段下载完成: %@, %ld, %ld", @(isDownloadFullData), _downloader.downloadSize, _downloader.length) ;
    if(_downloader.downloadType == DownloadType_AudioData) {
        [self startNextFragmentDownload] ;
    }
}

@end
