//
//  NSString+Extensions.h
//  Labrador
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extensions)

- (NSString *)md5;
- (NSString *)cachePath;
- (NSString *)cacheDir;

@end

NS_ASSUME_NONNULL_END
