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

/**
 Get Audio Data from DataProvider

 @param bytes the data pointer to be filled
 @param size size to fill
 @param offset offset
 @param type download type
 @return Actually filled size
 */
- (NSUInteger)getBytes:(void *)bytes
                  size:(NSUInteger)size
                offset:(NSUInteger)offset
                  type:(DownloadType)type;

/**
 Audio player is ready to play
 @param information audio information
 */
- (void)prepared:(LabradorAudioInformation)information;
@end
