//
//  LABAudioDataProviderProtocol.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "configure.h"


@protocol LabradorDataProvider <NSObject>
- (NSUInteger)getBytes:(void *)bytes size:(NSUInteger)size offset:(NSUInteger)offset type:(DownloadType)type;
- (void)receiveContentLength:(NSUInteger)contentLength;
@end
