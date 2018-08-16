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

@interface LabradorAudioPlayer()<LabradorInnerPlayerDataProvider, LabradorNetworkProviderDelegate>
{
    id<LabradorParse> _parser ;
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
        _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10022565790_320_1_1_0_sdk-cpm/0105/M00/67/84/ChR45FmNKxKAMbUaAKtt4_FdDfk806.mp3?xcode=bbf2b2c4511398b230d8c6d1e798ad0ca5fefcc" delegate:self] ;
        
    }
    return self;
}


- (void)startDecodeAndPlay {
    //注册一个空的NSPort,让线程保持
    _runloop = [NSRunLoop currentRunLoop] ;
    [_runloop addPort:_port forMode:NSRunLoopCommonModes] ;
    //初始化,并且开始读取音频头信息,解析音频元数据,为播放做准备
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
    _playStatus = LabradorAudioPlayerPlayStatusPrepared ;
    NSLog(@"[Cache]准备完成...") ;
    [_innerPlayer configureDescription:[_parser audioInformation].description] ;
    if(_delegate) [_delegate labradorAudioPlayerPrepared:self] ;
}


- (LabradorAudioFrame *)nextFrame {
    return [_parser product]  ;
}

#pragma mark - music control

- (void)prepare {
    //开始一个新的线程
    NSLog(@"[Cache]正在准备中...") ;
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

#pragma mark -

- (void)cacheStatusChanged:(LabradorCacheStatus)newCacheStatus {
    _loadingStatus = newCacheStatus ;
    switch (newCacheStatus) {
        case LabradorCacheStatusLoading:
            NSLog(@"[Cache]正在加载数据...") ;
            break ;
        case LabradorCacheStatusEnough:
            NSLog(@"[Cache]有足够的数据可以播放了...") ;
            break ;
    }
}
- (void)loadingPercent:(float)percent {
//    NSLog(@"加载进度: %f", percent) ;
}
@end
