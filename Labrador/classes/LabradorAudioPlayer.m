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
#import "LabradorProxyObject.h"

@interface LabradorAudioPlayer()<LabradorInnerPlayerDataProvider, LabradorNetworkProviderDelegate, LabradorDecoderDelegate>
{
    id<LabradorDecodable>           _decoder ;
    id<LabradorDataProvider>        _dataProvider ;
    LabradorInnerPlayer *           _innerPlayer ;
    NSPort *                        _port ;
    NSThread *                      _decodeAndPlayThread ;
    NSRunLoop *                     _runloop ;
    LabradorAudioInformation        _audioInformation ;
    NSTimer *                       _timer ;
    LabradorProxyObject *           _weakProxyObject ;
}
@end
@implementation LabradorAudioPlayer

- (void)dealloc
{
    [_timer invalidate] ;
    _timer = nil ;
    [_runloop removePort:_port forMode:NSRunLoopCommonModes] ;
    [_decodeAndPlayThread cancel] ;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _innerPlayer = [[LabradorInnerPlayer alloc] initWithProvider:self] ;
        _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10022565790_320_1_1_0_sdk-cpm/0105/M00/67/84/ChR45FmNKxKAMbUaAKtt4_FdDfk806.mp3?xcode=c5a686fc8f49da1d30ec30de60818390aca6a36" delegate:self] ;
        _weakProxyObject = [[LabradorProxyObject alloc] initWithTarget:self] ;
    }
    return self;
}
- (void)startDecodeAndPlay {
    _runloop = [NSRunLoop currentRunLoop] ;
    [_runloop addPort:_port forMode:NSRunLoopCommonModes] ;
    _decoder = [[LabradorDecoder alloc] init:self] ;
    _playStatus = LabradorAudioPlayerPlayStatusPrepared ;
    [_innerPlayer configureDescription:[_decoder audioInformation].description] ;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:_weakProxyObject selector:@selector(playTime) userInfo:nil repeats:YES] ;
    [self _prepareForPlay] ;
    [_runloop run] ;
}

#pragma mark - LabradorInnerPlayerDataProvider
- (LabradorAudioFrame *)nextFrame {
    return [_decoder product]  ;
}
#pragma mark - Delegate Control
- (void)_prepareForPlay {
    if(_delegate && [_delegate respondsToSelector:@selector(labradorAudioPlayerPrepared:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate labradorAudioPlayerPrepared:self] ;
        });
    }
}
- (void)_someErrorHappend:(NSError *)error {
    if(_delegate && [_delegate respondsToSelector:@selector(labradorAudioPlayerWithError:player:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate labradorAudioPlayerWithError:error player:self] ;
        });
    }
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
- (void)seek:(float)duration {
    [_innerPlayer cleanPlayData] ;
    [_decoder seek: duration / _audioInformation.duration * _audioInformation.audioDataByteCount + _audioInformation.dataOffset] ;
}
#pragma mark - Player Property
- (float)duration {
    return _audioInformation.duration ;
}
- (void)playTime {
    if(self.delegate &&
       [self.delegate respondsToSelector:@selector(labradorAudioPlayerPlaying:playTime:)] &&
       _playStatus == LabradorAudioPlayerPlayStatusPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate labradorAudioPlayerPlaying:self playTime:[_innerPlayer playTime]] ;
        });
    }
}
#pragma mark - LabradorNetworkProviderDelegate
- (void)statusChanged:(LabradorCacheMappingStatus)newStatus {
    _loadingStatus = newStatus ;
    switch (newStatus) {
        case LabradorCacheMappingStatusLoading:
            break ;
        case LabradorCacheMappingStatusEnough:
            break ;
    }
}
- (void)loadingPercent:(float)percent {
    if(self.delegate && [self.delegate respondsToSelector:@selector(labradorAudioPlayerCachingPercent:percent:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate labradorAudioPlayerCachingPercent:self percent:percent] ;
        });
    }
}
- (void)onError:(NSError *)error {
    [self _someErrorHappend:error] ;
}
#pragma mark - LabradorDecoderDelegate
- (NSUInteger)getBytes:(void *)bytes
                  size:(NSUInteger)size
                offset:(NSUInteger)offset
                  type:(DownloadType)type {
    return [_dataProvider getBytes:bytes size:size offset:offset type:type] ;
}
- (void)prepared:(LabradorAudioInformation)information {
    _audioInformation = information ;
    [_dataProvider prepared:information] ;
}
@end
