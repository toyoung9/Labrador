//
//  LABStore.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorCache.h"
#import "NSString+Extensions.h"

@interface LabradorCache()
{
    NSString *_urlString ;
    NSString *_cacheName;
    NSString *_cachePath ;
    LabradorCacheInformation _cache;
    size_t _headerLength ;
}
@end

@implementation LabradorCache

#pragma mark - initialize

- (void)dealloc
{
    if(_cache.data) free(_cache.data) ;
}
- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _urlString = urlString ;
        _cacheName = [[urlString md5] stringByAppendingString:@"_info"] ;
        _cachePath = [[_cacheName cacheDir] stringByAppendingPathComponent:_cacheName] ;
        NSLog(@"信息文件路径: %@", _cachePath) ;
        _headerLength = 32 + sizeof(UInt32) + sizeof(bool) ;
        if([[NSFileManager defaultManager] fileExistsAtPath:_cachePath]){
            NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:_cachePath] ;
            NSData *data = [handle readDataOfLength:_headerLength] ;
            if(_headerLength == data.length) {
                [data getBytes:&_cache length:_headerLength] ;
                [handle seekToFileOffset:_headerLength] ;
                NSData *cacheData = [handle readDataOfLength:_cache.length] ;
                if(cacheData.length == _cache.length) {
                    _cache.data = malloc(_cache.length) ;
                    [cacheData getBytes:_cache.data length:_cache.length] ;
                    NSLog(@"从文件初始化完成") ;
                }else{
                    _cache.is_initialized = false ;
                    NSLog(@"从文件初始未失败") ;
                }
            }
        } else {
            NSLog(@"未找到音频信息文件: %@", _cacheName) ;
        }
    }
    return self;
}
- (BOOL)isInitializedCache {
    return _cache.is_initialized ;
}
- (void)initializeLength:(NSUInteger)length {
    if(!_cache.is_initialized){
        NSLog(@"根据文件大小重新初始化") ;
        [[_cacheName dataUsingEncoding:NSUTF8StringEncoding] getBytes:_cache.name length:32];
        _cache.length = length / 1024 ;
        _cache.data = malloc(_cache.length) ;
        memset(_cache.data, 0, _cache.length) ;
        _cache.is_initialized = true ;
        [self synchronizeCacheInformation] ;
    } else {
        NSLog(@"不需要再次接受length配置") ;
    }
}
- (void)synchronizeCacheInformation{
    if(_cache.is_initialized) {
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:_headerLength + _cache.length] ;
        [data appendBytes:&_cache length:_headerLength] ;
        [data appendBytes:_cache.data length:_cache.length] ;
        BOOL ret = [data writeToFile:_cachePath atomically:YES] ;
        if(ret) {
            NSLog(@"同步音频文件到磁盘成功") ;
        } else {
            NSLog(@"同步音频文件到磁盘失败") ;
        }
    }
}
- (void)completedFragment:(NSUInteger)start length:(NSUInteger)length {
    if(start >= _cache.length || length == 0) return ;
    size_t _s = start / 1024 ;
    NSUInteger _l = length / 1024 ;
    memset(_cache.data + _s, 0xFF, _l) ;
    [self synchronizeCacheInformation] ;
    NSLog(@"完成一个映射片段: %ld, %ld", start, length) ;
}

- (NSRange)findNextDownloadFragment {
    if(!_cache.is_initialized) return NSMakeRange(0, 0) ;
    NSUInteger start = 0 ;
    NSUInteger length = 0 ;
    //find start location
    while (*(_cache.data + start) == 0xFF) {
        start ++ ;
    }
    //find fragment length
    if(start < _cache.length) {
        while (*(_cache.data + start + length) == 0x00) {
            length ++ ;
        }
    }
    return NSMakeRange(start, length) ;
}

- (NSRange)findNextCacheFragmentFrom:(NSUInteger)from {
    NSUInteger start = from ;
    NSUInteger length = 0 ;
    //find fragment length
    if(start < _cache.length) {
        while (*(_cache.data + start + length) == 0xFF) {
            length ++ ;
        }
    }
    return NSMakeRange(start, length) ;
}

@end
