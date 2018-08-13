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
    NSString *_cacheInformationPath ;
}
@end

@implementation LabradorCache

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _urlString = urlString ;
        NSString *cacheInformationName = [[urlString md5] stringByAppendingString:@"_info"] ;
        _cacheInformationPath = [cacheInformationName cachePath] ;
    }
    return self;
}

@end
