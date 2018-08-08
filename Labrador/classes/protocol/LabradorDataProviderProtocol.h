//
//  LABAudioDataProviderProtocol.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LabradorDataProviderProtocol <NSObject>
- (uint32_t)getBytes:(void *)bytes size:(uint32_t)size offset:(uint32_t)offset;
@end
