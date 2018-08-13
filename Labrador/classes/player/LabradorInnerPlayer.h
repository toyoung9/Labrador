//
//  LabradorInnerPlayer.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import "LabradorAudioPacket.h"
#import "LabradorDataProvider.h"

@protocol LabradorInnerPlayerDataProvider <NSObject>
- (LabradorAudioFrame *)getNextFrame ;
@end
@interface LabradorInnerPlayer : NSObject

- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithDescription:(AudioStreamBasicDescription)description
                           provider:(id<LabradorInnerPlayerDataProvider>)provider;

@end
