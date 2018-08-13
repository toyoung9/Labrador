//
//  LABAudioDescpriptionProtocol.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

@class LabradorAudioFrame ;
@protocol LabradorParse <NSObject>
- (AudioStreamBasicDescription)parse;
- (LabradorAudioFrame *)product:(UInt32)minByteSize;
@end

