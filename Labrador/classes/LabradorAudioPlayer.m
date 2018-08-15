//
//  LABAudioPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAudioPlayer.h"
#import "LabradorParse.h"
#import "LabradorDataProvider.h"
#import "LabradorAFSParser.h"
#import "LabradorLocalProvider.h"
#import "LabradorInnerPlayer.h"
#import "configure.h"
#import "LabradorNetworkProvider.h"

@interface LabradorAudioPlayer()<LabradorInnerPlayerDataProvider>
{
    id<LabradorParse> _parser ;
    id<LabradorDataProvider> _dataProvider ;
    LabradorInnerPlayer *_innerPlayer ;

}
@end
@implementation LabradorAudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {

        [self initializeParser] ;
        [self initializeInnerPlayer] ;
    }
    return self;
}

- (void)initializeParser {
    _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10021342883_320_1_1_0_sdk-cpm/0104/M00/61/40/ChR45FmMkMCAHtDPAIv0vkFSMQk337.mp3?xcode=13d8cc1015ca581430bfa37cddf46355c50b6ec"] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
}
- (void)initializeInnerPlayer {
    AudioStreamBasicDescription description = [_parser audioInformation].description ;
    NSAssert(description.mSampleRate > 0, @"LabradorParse initialize failure.") ;
    _innerPlayer = [[LabradorInnerPlayer alloc] initWithDescription:description provider:self] ;
}

- (LabradorAudioFrame *)nextFrame {
    return [_parser product]  ;
}

#pragma mark - music control
- (void)play{
    [_innerPlayer play] ;
}
- (void)pause {
    [_innerPlayer pause] ;
}
- (void)resume {
    [_innerPlayer resume] ;
}

@end
