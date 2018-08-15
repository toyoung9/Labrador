//
//  LABAudioDescpriptionProtocol.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

struct LabradorAudioInformation{
    AudioStreamBasicDescription description ;
    SInt64 dataOffset ;
    UInt64 audioDataByteCount ;
    UInt32 bitRate ;
    UInt64 audioDataPacketCount ;
    float duration ;
};
typedef struct LabradorAudioInformation LabradorAudioInformation;

@class LabradorAudioFrame ;
@protocol LabradorParse <NSObject>
- (LabradorAudioInformation)audioInformation;
- (LabradorAudioFrame *)product;
@end

