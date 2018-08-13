//
//  LabradorLocalProvider.m
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorLocalProvider.h"

@interface LabradorLocalProvider()
{
    NSFileHandle *_handle ;
}
@end
@implementation LabradorLocalProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"t" ofType:@"mp3"] ;
        _handle = [NSFileHandle fileHandleForReadingAtPath:path] ;
        
    }
    return self;
}
- (uint32_t)getBytes:(void *)bytes size:(uint32_t)size offset:(uint32_t)offset{
    [_handle seekToFileOffset:offset] ;
    NSData *data = [_handle readDataOfLength:size] ;
    [data getBytes:bytes length:data.length] ;
    return (uint32_t)data.length ;
}

@end
