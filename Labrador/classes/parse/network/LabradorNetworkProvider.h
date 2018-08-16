//
//  LabradorNetworkProvider.h
//  Labrador
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LabradorDataProvider.h"

NS_ASSUME_NONNULL_BEGIN



@protocol LabradorNetworkProviderDelegate <NSObject>

- (void)cacheStatusChanged:(LabradorCacheStatus)newCacheStatus ;
- (void)loadingPercent:(float)percent ;

@end

@interface LabradorNetworkProvider : NSObject<LabradorDataProvider>
@property (nonatomic, assign)LabradorCacheStatus cacheStatus ;
@property (nonatomic, weak)id<LabradorNetworkProviderDelegate> delegate ;
- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString delegate:(id<LabradorNetworkProviderDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END

