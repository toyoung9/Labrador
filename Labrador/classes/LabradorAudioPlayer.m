//
//  LABAudioPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAudioPlayer.h"
#import "LABCacheManager.h"
#import "LabradorParse.h"
#import "LabradorDataProvider.h"
#import "LabradorAFSParser.h"
#import "LabradorLocalProvider.h"
#import "LabradorInnerPlayer.h"
#import "configure.h"

@interface LabradorAudioPlayer()<LabradorInnerPlayerDataProvider>
{
    //store manager: download and store caching information
    LABCacheManager *_storeManager ;
    id<LabradorParse> _parser ;
    id<LabradorDataProvider> _dataProvider ;
    LabradorInnerPlayer *_player ;
    
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
    _dataProvider = [[LabradorLocalProvider alloc] init] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
}
- (void)initializeInnerPlayer {
    AudioStreamBasicDescription description = _parser.parse ;
    NSAssert(description.mSampleRate > 0, @"LabradorParse initialize failure.") ;
    _player = [[LabradorInnerPlayer alloc] initWithDescription:description provider:self] ;
}

- (LabradorAudioFrame *)getNextFrame {
    LabradorAudioFrame *frame = [_parser product:LabradorAudioQueueBufferCacheSize] ;
    return frame ;//[[LabradorAudioFrame alloc] initWithPackets:tmps packetSize:byteSie] ;
}
@end
