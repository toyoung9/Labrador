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
    
    dispatch_queue_t _produceQueue ;
    dispatch_queue_t _playQueue ;
}
@end
@implementation LabradorAudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _produceQueue = dispatch_queue_create("Audio Frame Product Queue", NULL) ;
        _playQueue = dispatch_queue_create("Playe Queue", NULL) ;
        
        [self initializeParser] ;
        [self initializeInnerPlayer] ;
    }
    return self;
}

- (void)initializeParser {
    _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/114_95_T10038823662_128_1_1_0_sdk-cpm/0209/M00/10/CE/ChR461nwEPeAOvBqADnhADpvBvg660.mp3?xcode=c89031ed5bcbac9830ac03cbd89d63ccc574fc4"] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
}
- (void)initializeInnerPlayer {
    AudioStreamBasicDescription description = [_parser getAudioStreamBasicDescription] ;
    NSAssert(description.mSampleRate > 0, @"LabradorParse initialize failure.") ;
    _innerPlayer = [[LabradorInnerPlayer alloc] initWithDescription:description provider:self] ;
}

- (LabradorAudioFrame *)getNextFrame {
    LabradorAudioFrame *frame = [_parser product:LabradorAudioQueueBufferCacheSize] ;
    return frame ;//[[LabradorAudioFrame alloc] initWithPackets:tmps packetSize:byteSie] ;
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
