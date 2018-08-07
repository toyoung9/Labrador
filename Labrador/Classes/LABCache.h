//
//  LABStore.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

struct LABCacheInformation {
    char name[32];//MD5 name
    int length;//file length
    void *data;//data mapping(1byte -> 1024byte)
}LABCacheInformation;

NS_ASSUME_NONNULL_BEGIN

@interface LABCache : NSObject

@end

NS_ASSUME_NONNULL_END
