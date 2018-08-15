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

typedef NS_ENUM(NSInteger,LabradorCache_Status){
    LabradorCache_Status_Loading = 1, //downloading data
    LabradorCache_Status_Enough,//enough cache data
    LabradorCache_Status_Preparing,
    LabradorCache_Status_Prepared,
};

@protocol LabradorNetworkProviderDelegate <NSObject>

- (void)cacheStatusChanged:(LabradorCache_Status)newCacheStatus ;
- (void)loadingPercent:(float)percent ;

@end

@interface LabradorNetworkProvider : NSObject<LabradorDataProvider>
@property (nonatomic, assign)LabradorCache_Status cacheStatus ;
@property (nonatomic, weak)id<LabradorNetworkProviderDelegate> delegate ;
- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString delegate:(id<LabradorNetworkProviderDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END

