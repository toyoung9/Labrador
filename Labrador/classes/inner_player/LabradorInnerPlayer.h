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


typedef NS_ENUM(NSInteger, LabradorAudioPlayer_Status){
    LabradorAudioPlayer_Status_Stop = 0,
    LabradorAudioPlayer_Status_Playing = 1,
    LabradorAudioPlayer_Status_Pause = 2,
};

@protocol LabradorInnerPlayerDataProvider <NSObject>
- (LabradorAudioFrame *)nextFrame ;
@end
@interface LabradorInnerPlayer : NSObject

- (instancetype)init NS_UNAVAILABLE ;
- (instancetype)initWithDescription:(AudioStreamBasicDescription)description
                           provider:(id<LabradorInnerPlayerDataProvider>)provider;
- (void)play ;
- (void)pause ;
- (void)resume ;
@end
