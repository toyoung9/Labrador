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
    _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10022565790_320_1_1_0_sdk-cpm/0105/M00/67/84/ChR45FmNKxKAMbUaAKtt4_FdDfk806.mp3?xcode=d6b108577011d5c930bca0dc489b75428d723ee"] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
}
- (void)initializeInnerPlayer {
    AudioStreamBasicDescription description = [_parser getAudioStreamBasicDescription] ;
    NSAssert(description.mSampleRate > 0, @"LabradorParse initialize failure.") ;
    _innerPlayer = [[LabradorInnerPlayer alloc] initWithDescription:description provider:self] ;
}

- (LabradorAudioFrame *)getNextFrame {
    LabradorAudioFrame *frame = [_parser product:LabradorAudioQueueBufferCacheSize] ;
    return frame ;
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
