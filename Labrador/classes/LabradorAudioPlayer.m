//
//  LABAudioPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAudioPlayer.h"
#import "LABCacheManager.h"
#import "LabradorParseProtocol.h"
#import "LabradorDataProviderProtocol.h"
#import "LabradorAFSParser.h"
#import "LabradorLocalProvider.h"
#import "LabradorInnerPlayer.h"

@interface LabradorAudioPlayer()
{
    //store manager: download and store caching information
    LABCacheManager *_storeManager ;
    id<LabradorParseProtocol> _parser ;
    id<LabradorDataProviderProtocol> _dataProvider ;
    LabradorInnerPlayer *_player ;
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
    _dataProvider = [[LabradorLocalProvider alloc] init] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
}
- (void)initializeInnerPlayer {
    AudioStreamBasicDescription description = _parser.parse ;
    NSAssert(description.mSampleRate > 0, @"LabradorParseProtocol initialize failure.") ;
    _player = [[LabradorInnerPlayer alloc] initWithDescription:_parser.parse] ;
}

@end
