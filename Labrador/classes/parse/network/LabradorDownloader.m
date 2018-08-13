//
//  LABDownloader.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorDownloader.h"

@interface LabradorDownloader()
{
    NSString *_urlString ;
}
@end

@implementation LabradorDownloader

#pragma mark - initialize

- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _urlString = urlString ;
    }
    return self;
}

@end
