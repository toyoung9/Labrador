//
//  LabradorAudioDataModel.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

struct LabradorAudioData{
    void * const                    mAudioData;
    UInt32                          mAudioDataByteSize;
    AudioStreamPacketDescription * const __nullable mPacketDescriptions;
    UInt32                          mPacketDescriptionCount;
};
typedef struct LabradorAudioData LabradorAudioData;

@interface LabradorAudioDataModel : NSObject
@property(nonatomic, assign)LabradorAudioData audioData ;
@end
