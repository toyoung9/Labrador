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
    //data url
    NSString *_urlString ;
    //min size for play
    UInt32 _minSize;
    //cache manager for mapping
    LabradorCache *_cache ;
    //download audio data from network
    LabradorDownloader *_downloader ;
    //lock for read & write cache file
    NSCondition *_lock ;
    //write data when receive from network
    NSFileHandle *_dataWriteHandle ;
    //read data from cache file for play
    NSFileHandle *_dataReadHandle ;
}
@end
@implementation LabradorNetworkProvider

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString * _Nonnull)urlString delegate:(nonnull id<LabradorNetworkProviderDelegate>)delegate
{
    self = [super init];
    if (self) {
        _minSize = 1024 * 128 ;
        _lock = [[NSCondition alloc] init] ;
        _urlString = urlString ;
        _delegate = delegate ;
        _cache = [[LabradorCache alloc] initWithURLString:_urlString] ;
        [self initializeFileHandle] ;
    }
    return self;
}

- (void)initializeFileHandle {
    NSString *path = [_urlString cachePath] ;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:NULL attributes:NULL] ;
    }
    _dataWriteHandle = [NSFileHandle fileHandleForWritingAtPath:path] ;
    _dataReadHandle = [NSFileHandle fileHandleForReadingAtPath:path] ;
}

- (void)notifyStatus:(LabradorCacheStatus)status{
    if(_cacheStatus == status) return ;
    _cacheStatus = status ;
    if(_delegate) [_delegate cacheStatusChanged:_cacheStatus] ;
}
- (void)notifyPercent {
    if(_delegate) [_delegate loadingPercent:_cache.cachePercent] ;
}
- (void)start {
    if(_cache.isInitializedCache) {
        if([_cache hasEnoughData:_minSize from:0]) {
            [self notifyStatus:LabradorCacheStatusEnough] ;
        } else {
            [self notifyStatus:LabradorCacheStatusLoading] ;
        }
        [self notifyPercent] ;
        [self startNextFragmentDownload] ;
    }
}

//start new fragment download
- (void)startNextFragmentDownload {
    NSRange range = [_cache findNextDownloadFragment] ;
    if(range.length >= _minSize * 4) {
        range.length = _minSize * 4 ;
    }
    if(range.length == 0) return ;
    _downloader = [[LabradorDownloader alloc] initWithURLString:_urlString
                                                          start:range.location
                                                         length:range.length
                                                   downloadType:DownloadTypeAudioData] ;
    _downloader.delegate = self ;
    [_downloader start] ;
}

#pragma mark - LabradorDataProvider implementation

- (NSUInteger)getBytes:(void *)bytes
                  size:(NSUInteger)size
                offset:(NSUInteger)offset
                  type:(DownloadType)type{
    NSAssert(size <= _minSize, @"_minSize must be >= size") ;
    NSUInteger length = 0 ;
    //cache file
    [_lock lock] ;
    if(type == DownloadTypeHeader) {
        //read header information
        NSRange headerRange = [_cache findNextCacheFragmentFrom:0] ;
        if(headerRange.length < size) {
            _downloader = [[LabradorDownloader alloc] initWithURLString:_urlString
                                                                  start:0
                                                                 length:LabradorAudioHeaderInputSize
                                                           downloadType:type] ;
            _downloader.delegate = self ;
            [self notifyPercent] ;
            [_downloader start] ;
            [_lock wait] ;
        }
        [_dataReadHandle seekToFileOffset:0] ;
        NSData *data = [_dataReadHandle readDataOfLength:size] ;
        [data getBytes:bytes range:NSMakeRange(0, size)] ;
        length = data.length ;
    } else {
        //查找接下来连续缓存区是否满足最小设定
        NSRange range = [_cache findNextCacheFragmentFrom:_downloader.startLocation] ;
        if(range.length < _minSize) {
            //不满足,则等待数据下载
            [self notifyStatus:LabradorCacheStatusLoading] ;
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
    //receive data from network
    if(data && data.length > 0) {
        [_lock lock] ;
        [_dataWriteHandle seekToFileOffset:start] ;
        [_dataWriteHandle writeData:data] ;
        //写入映射缓存
        [_cache completedFragment:start length:data.length] ;
        if(_downloader.downloadType == DownloadTypeHeader) {
            // download header information data
            if([_downloader downloadCompleted]) {
                [_lock signal] ;
            }
        } else {
            if([_cache hasEnoughData:_minSize from:(UInt32)_downloader.startLocation]) {
                [_lock signal] ;
                [self notifyStatus:LabradorCacheStatusEnough] ;
            }
        }
        [self notifyPercent] ;
        [_lock unlock] ;
    }
}
- (void)receiveContentLength:(NSUInteger)contentLength{
    //初始化头信息与缓存映射文件信息
    NSLog(@"文件大小: %lu", contentLength) ;
    if(_downloader.downloadType == DownloadTypeHeader) {
        _downloader = nil ;
        [_cache initializeLength:contentLength] ;
        [self startNextFragmentDownload] ;
    }
}
- (void)completed:(BOOL)isDownloadFullData {
    NSLog(@"片段下载完成: %@, %ld, %ld", @(isDownloadFullData), _downloader.downloadSize, _downloader.length) ;
    
    if(_downloader.downloadType == DownloadTypeAudioData) {
        _downloader = nil ;
        [self startNextFragmentDownload] ;
    }
}

@end
