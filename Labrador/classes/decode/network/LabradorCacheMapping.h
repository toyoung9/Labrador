//
//  LABStore.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "configure.h"

NS_ASSUME_NONNULL_BEGIN

@interface LabradorCacheMapping : NSObject
- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString ;
- (void)configureCacheMappingWithFileSize:(NSUInteger)fileSize ;
- (void)completedFragment:(NSUInteger)start length:(NSUInteger)length;
- (NSRange)findNextDownloadFragment;
- (NSRange)findNextCacheFragmentFrom:(NSUInteger)from ;
- (BOOL)hasEnoughData:(UInt32)minSize from:(UInt32)from ;
- (float)cachePercent;
@end

NS_ASSUME_NONNULL_END
