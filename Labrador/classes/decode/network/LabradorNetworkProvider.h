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

- (void)statusChanged:(LabradorCacheMappingStatus)newStatus ;
- (void)loadingPercent:(float)percent ;
- (void)onError:(NSError *)error ;
@end

@interface LabradorNetworkProvider : NSObject<LabradorDataProvider>
@property (nonatomic, assign)LabradorCacheMappingStatus cacheStatus ;
@property (nonatomic, weak)id<LabradorNetworkProviderDelegate> delegate ;
- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString
                         delegate:(id<LabradorNetworkProviderDelegate> _Nonnull)delegate;
@end

NS_ASSUME_NONNULL_END

