//
//  LABAudioDescpriptionProtocol.h
//  Labrador
//
//  Created by legendry on 2018/8/8.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>

@protocol LabradorParseProtocol <NSObject>
- (AudioStreamBasicDescription)parse;
@end

