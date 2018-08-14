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
    UInt32 length;//file length
    bool is_initialized;//
    unsigned char *data;//data mapping(1byte -> 1024byte)
};
typedef struct LabradorCacheInformation LabradorCacheInformation;

NS_ASSUME_NONNULL_BEGIN

@interface LabradorCache : NSObject

- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString ;

- (void)initializeLength:(NSUInteger)length ;
- (void)completedFragment:(NSUInteger)start length:(NSUInteger)length;
- (NSRange)findNextDownloadFragment;
- (NSRange)findNextCacheFragmentFrom:(NSUInteger)from ;
- (BOOL)isInitializedCache;

@end

NS_ASSUME_NONNULL_END
