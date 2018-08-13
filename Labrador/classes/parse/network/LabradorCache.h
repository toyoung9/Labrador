//
//  LABStore.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

struct LabradorCacheInformation {
    char name[32];//MD5 name
    int length;//file length
    void *data;//data mapping(1byte -> 1024byte)
};
typedef struct LABCacheInformation LABCacheInformation;

NS_ASSUME_NONNULL_BEGIN

@interface LabradorCache : NSObject

- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString ;

@end

NS_ASSUME_NONNULL_END
