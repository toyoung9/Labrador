//
//  NSStringExtensionsTests.m
//  LabradorTests
//
//  Created by legendry on 2018/8/13.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "NSStringExtensionsTests.h"
#import "NSString+Extensions.h"

@implementation NSStringExtensionsTests

- (void)testMD5 {
    NSString *str = @"Labrador" ;
    NSString *md5_result = [str md5] ;
    NSString *target = @"64e6aeaee5fb88b89c566f93d4e3e20d" ;
    XCTAssertTrue([md5_result isEqualToString:target]) ;
}

- (void)testCacheDir {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/labrador_cache"] ;
    XCTAssertTrue([cacheDir isEqualToString:[@"" cacheDir]]) ;
}

- (void)testCachePath {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/labrador_cache"] ;
    NSString *md5 = @"dsfasfasfasfsafas" ;
    XCTAssertTrue([[cacheDir stringByAppendingPathComponent:[md5 md5]] isEqualToString:[md5 cachePath]]) ;
}

@end
