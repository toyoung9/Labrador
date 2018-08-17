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
    //download audio header and data from network
    LabradorDownloader *_downloader ;
    //lock for read & write cache file
    NSCondition *_lock ;
    //write data when receive from network
    NSFileHandle *_fileWriteHandle ;
    //read data from cache file for play
    NSFileHandle *_fileReadHandle ;
}
@end

@implementation LabradorNetworkProvider

- (instancetype)initWithURLString:(NSString * _Nonnull)urlString
                         delegate:(nonnull id<LabradorNetworkProviderDelegate>)delegate
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
    _fileWriteHandle = [NSFileHandle fileHandleForWritingAtPath:path] ;
    _fileReadHandle = [NSFileHandle fileHandleForReadingAtPath:path] ;
}

#pragma mark - Download Control
- (void)startNextFragmentDownload {
    NSRange range = [_cache findNextDownloadFragment] ;
    if(range.length == 0) return ;
    _downloader = [[LabradorDownloader alloc] initWithURLString:_urlString
                                                          start:range.location
                                                         length:MIN(range.length, _minSize * 4)
                                                   downloadType:DownloadTypeAudioData] ;
    _downloader.delegate = self ;
    [_downloader start] ;
}

#pragma mark - LabradorDataProvider Delegate
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
        [_fileReadHandle seekToFileOffset:0] ;
        NSData *data = [_fileReadHandle readDataOfLength:size] ;
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
        [_fileReadHandle seekToFileOffset:offset] ;
        NSData *data = [_fileReadHandle readDataOfLength:size] ;
        [data getBytes:bytes range:NSMakeRange(0, size)] ;
        length = data.length ;
    }
    [_lock unlock] ;
    return length ;
}


- (void)prepared:(LabradorAudioInformation)information{
    //初始化头信息与缓存映射文件信息
    if(_downloader.downloadType == DownloadTypeHeader) {
        _downloader = nil ;
        [_cache initializeLength:information.totalSize] ;
        [self startNextFragmentDownload] ;
    }
}

#pragma mark - Downloader Delegate
//receive from current downloader
- (void)receiveData:(NSData *)data start:(NSUInteger)start{
    //receive data from network
    if(data && data.length > 0) {
        [_lock lock] ;
        [_fileWriteHandle seekToFileOffset:start] ;
        [_fileWriteHandle writeData:data] ;
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
//current downloader download completed
- (void)completed:(BOOL)isDownloadFullData {
    if(_downloader.downloadType == DownloadTypeAudioData) {
        _downloader = nil ;
        [self startNextFragmentDownload] ;
    }
}

#pragma mark - Notify
- (void)notifyStatus:(LabradorCacheStatus)status{
    if(_cacheStatus == status) return ;
    _cacheStatus = status ;
    if(_delegate && [_delegate respondsToSelector:@selector(cacheStatusChanged:)]) [_delegate cacheStatusChanged:_cacheStatus] ;
}
- (void)notifyPercent {
    if(_delegate && [_delegate respondsToSelector:@selector(loadingPercent:)]) [_delegate loadingPercent:_cache.cachePercent] ;
}

@end
