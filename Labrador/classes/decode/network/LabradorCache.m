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
    UInt32 _cacheCount ;
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
                    [self initializeCacheCount] ;
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

- (void)initializeCacheCount {
    int index = 0 ;
    while (index < _cache.length) {
        if(*(_cache.data + index) == 0xFF) _cacheCount ++ ;
        index ++ ;
    }
}
- (BOOL)isInitializedCache {
    return _cache.is_initialized ;
}
- (void)initializeLength:(NSUInteger)length {
    if(!_cache.is_initialized){
        [[_cacheName dataUsingEncoding:NSUTF8StringEncoding] getBytes:_cache.name length:32];
        _cache.length = (UInt32)ceil(length * 1.0f / 1024) ;
        _cache.data = malloc(_cache.length) ;
        memset(_cache.data, 0, _cache.length) ;
        _cache.is_initialized = true ;
        [self synchronize] ;
        NSLog(@"根据文件大小重新初始化,映射大小: %u", _cache.length) ;
        _cacheCount = 0 ;
    } else {
        NSLog(@"不需要再次接受length配置") ;
    }
}
- (void)synchronize {
    if(_cache.is_initialized) {
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:_headerLength + _cache.length] ;
        [data appendBytes:&_cache length:_headerLength] ;
        [data appendBytes:_cache.data length:_cache.length] ;
        [data writeToFile:_cachePath atomically:YES] ;
    }
}
- (void)completedFragment:(NSUInteger)start length:(NSUInteger)length {
    if(start + length >= _cache.length * 1024 || length == 0) return ;
    size_t _s = start / 1024 ;
    NSUInteger _l = ceil(length * 1.0f / 1024) ;
    memset(_cache.data + _s, 0xFF, _l) ;
    [self synchronize] ;
    _cacheCount += _l ;
}

- (NSRange)findNextDownloadFragment {
    if(!_cache.is_initialized) return NSMakeRange(0, 0) ;
    NSUInteger start = 0 ;
    NSUInteger length = 0 ;
    //find start location
    while (*(_cache.data + start) != 0x00) {
        start ++ ;
    }
    //find fragment length
    if(start < _cache.length) {
        while (*(_cache.data + start + length) == 0x00 && start + length < _cache.length) {
            length ++ ;
        }
    }
    return NSMakeRange(start * 1024, MIN(length, _cache.length) * 1024) ;
}

- (NSRange)findNextCacheFragmentFrom:(NSUInteger)from {
    NSUInteger start = from / 1024 ;
    NSUInteger length = 0 ;
    //find fragment length
    if(start < _cache.length) {
        while (*(_cache.data + start + length) == 0xFF) {
            length ++ ;
        }
    }
    return NSMakeRange(from, MIN(length, _cache.length) * 1024) ;
}

- (BOOL)hasEnoughData:(UInt32)minSize from:(UInt32)from {
    NSRange range = [self findNextCacheFragmentFrom:from] ;
    return range.length >= minSize ;
}

- (float)cachePercent {
    if(_cache.length == 0) return 0 ;
    return _cacheCount * 1.0 / _cache.length ;
}


@end
