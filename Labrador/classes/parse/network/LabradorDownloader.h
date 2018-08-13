//
//  LABDownloader.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LabradorDownloaderDelegate <NSObject>

- (void)downloadData:(NSData *)data ;

@end

@interface LabradorDownloader : NSObject

@property (nonatomic, weak)id<LabradorDownloaderDelegate> delegate ;

- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithURLString:(NSString * _Nonnull)urlString ;


@end

NS_ASSUME_NONNULL_END
