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


@interface LabradorNetworkProvider()<LabradorDownloaderDelegate>
{
    NSString *_urlString ;
    LabradorCache *_cache ;
    LabradorDownloader *_dowmloader ;
    NSCondition *_lock ;
}
@end
@implementation LabradorNetworkProvider

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString * _Nonnull)urlString
{
    self = [super init];
    if (self) {
        _urlString = urlString ;
        _cacheStatus = LabradorCache_Status_Caching ;
        _cache = [[LabradorCache alloc] initWithURLString:_urlString] ;
        if(_delegate){
            [_delegate cacheStatusChanged:_cacheStatus] ;
        }
    }
    return self;
}

#pragma mark - LabradorDataProvider implementation

- (uint32_t)getBytes:(void *)bytes size:(uint32_t)size offset:(uint32_t)offset {
    return 0 ;
}

- (void)downloadData:(NSData *)data {
    [_lock lock] ;
    
    [_lock unlock] ;
}

@end
