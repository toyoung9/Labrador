//
//  LABAudioPlayer.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "LabradorAudioPlayer.h"
#import "LabradorDecodable.h"
#import "LabradorDataProvider.h"
#import "LabradorDecoder.h"
#import "LabradorLocalProvider.h"
#import "LabradorInnerPlayer.h"
#import "configure.h"
#import "LabradorNetworkProvider.h"

@interface LabradorAudioPlayer()<LabradorInnerPlayerDataProvider, LabradorNetworkProviderDelegate, LabradorDecoderDelegate>
{
    id<LabradorDecodable> _parser ;
    id<LabradorDataProvider> _dataProvider ;
    LabradorInnerPlayer *_innerPlayer ;
    NSPort *_port ;
    NSThread *_decodeAndPlayThread ;
    NSRunLoop *_runloop ;
}
@end
@implementation LabradorAudioPlayer

- (void)dealloc
{
    [_runloop removePort:_port forMode:NSRunLoopCommonModes] ;
    [_decodeAndPlayThread cancel] ;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化音频播放器(基于Audio Queue)
        _innerPlayer = [[LabradorInnerPlayer alloc] initWithProvider:self] ;
        //初始化数据提供器(网络数据提供器)
        _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10022565790_320_1_1_0_sdk-cpm/0105/M00/67/84/ChR45FmNKxKAMbUaAKtt4_FdDfk806.mp3?xcode=3c7fcb9880f4eaf530e9997ce18f2c801af5da3" delegate:self] ;
        
    }
    return self;
}

- (void)startDecodeAndPlay {
    _runloop = [NSRunLoop currentRunLoop] ;
    [_runloop addPort:_port forMode:NSRunLoopCommonModes] ;
    _parser = [[LabradorDecoder alloc] init:self] ;
    _playStatus = LabradorAudioPlayerPlayStatusPrepared ;
    [_innerPlayer configureDescription:[_parser audioInformation].description] ;
    if(_delegate) [_delegate labradorAudioPlayerPrepared:self] ;
}

#pragma mark - LabradorInnerPlayerDataProvider
- (LabradorAudioFrame *)nextFrame {
    return [_parser product]  ;
}

#pragma mark - Music Control

- (void)prepare {
    _playStatus = LabradorAudioPlayerPlayStatusPreparing ;
    _port = [NSPort port] ;
    _decodeAndPlayThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDecodeAndPlay) object:nil] ;
    _decodeAndPlayThread.name = @"Play & Decode" ;
    [_decodeAndPlayThread start] ;
}
- (void)play{
    if(_playStatus == LabradorAudioPlayerPlayStatusPrepared) {
        [_innerPlayer play] ;
        _playStatus = LabradorAudioPlayerPlayStatusPlaying ;
    }
}
- (void)pause {
    if(_playStatus == LabradorAudioPlayerPlayStatusPlaying) {
        [_innerPlayer pause] ;
        _playStatus = LabradorAudioPlayerPlayStatusPause ;
    }
}
- (void)resume {
    if(_playStatus == LabradorAudioPlayerPlayStatusPause) {
        [_innerPlayer resume] ;
        _playStatus = LabradorAudioPlayerPlayStatusPlaying ;
    }
}

#pragma mark - LabradorNetworkProviderDelegate

- (void)cacheStatusChanged:(LabradorCacheStatus)newCacheStatus {
    _loadingStatus = newCacheStatus ;
    switch (newCacheStatus) {
        case LabradorCacheStatusLoading:
            break ;
        case LabradorCacheStatusEnough:
            break ;
    }
}
- (void)loadingPercent:(float)percent {
//    NSLog(@"加载进度: %f", percent) ;
}

#pragma mark - LabradorDecoderDelegate

- (NSUInteger)getBytes:(void *)bytes
                  size:(NSUInteger)size
                offset:(NSUInteger)offset
                  type:(DownloadType)type {
    return [_dataProvider getBytes:bytes size:size offset:offset type:type] ;
}

- (void)prepared:(LabradorAudioInformation)information {
    [_dataProvider prepared:information] ;
}
@end
