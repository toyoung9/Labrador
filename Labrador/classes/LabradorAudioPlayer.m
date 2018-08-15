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
    NSThread *_thread ;
    NSRunLoop *_runloop ;
}
@end
@implementation LabradorAudioPlayer

- (void)dealloc
{
    [_runloop removePort:_port forMode:NSRunLoopCommonModes] ;
    [_thread cancel] ;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeThread] ;
    }
    return self;
}

- (void)initializeThread {
    _port = [NSPort port] ;
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(initializeInThread) object:nil] ;
    _thread.name = @"Play & Decode" ;
    [_thread start] ;
}

- (void)initializeInThread {
    _runloop = [NSRunLoop currentRunLoop] ;
    [_runloop addPort:_port forMode:NSRunLoopCommonModes] ;
    
    [self initialize] ;

    
}

- (void)initialize {
    _dataProvider = [[LabradorNetworkProvider alloc] initWithURLString:@"http://audio01.dmhmusic.com/133_48_T10022565790_320_1_1_0_sdk-cpm/0105/M00/67/84/ChR45FmNKxKAMbUaAKtt4_FdDfk806.mp3?xcode=cb789e385bd2c36830c1ab0b8449598bf19cadf" delegate:self] ;
    _innerPlayer = [[LabradorInnerPlayer alloc] initWithProvider:self] ;
    _parser = [[LabradorAFSParser alloc] init:_dataProvider] ;
    
}

- (LabradorAudioFrame *)nextFrame {
    return [_parser product]  ;
}

#pragma mark - music control

- (void)prepare {
    [_dataProvider prepare] ;
}
- (void)play{
    if(_cacheStatus == LabradorCache_Status_Prepared) {
        [_innerPlayer play] ;
        _status = LabradorAudioPlayer_Status_Playing ;
    }
}
- (void)pause {
    if(_status == LabradorAudioPlayer_Status_Playing) {
        [_innerPlayer pause] ;
        _status = LabradorAudioPlayer_Status_Pause ;
    }
}
- (void)resume {
    if(_status == LabradorAudioPlayer_Status_Pause) {
        [_innerPlayer resume] ;
        _status = LabradorAudioPlayer_Status_Playing ;
    }
}

#pragma mark -

- (void)cacheStatusChanged:(LabradorCache_Status)newCacheStatus {
    _cacheStatus = newCacheStatus ;
    switch (newCacheStatus) {
        case LabradorCache_Status_Preparing:
            NSLog(@"[Cache]正在准备中...") ;
            break;
        case LabradorCache_Status_Prepared:
            NSLog(@"[Cache]准备完成...") ;
            [_dataProvider start] ;
            [_innerPlayer configureDescription:[_parser audioInformation].description] ;
            if(_delegate) [_delegate labradorAudioPlayerPrepared:self] ;
            break ;
        case LabradorCache_Status_Loading:
            NSLog(@"[Cache]正在加载数据...") ;
            break ;
        case LabradorCache_Status_Enough:
            NSLog(@"[Cache]有足够的数据可以播放了...") ;
            break ;
    }
}
- (void)loadingPercent:(float)percent {
//    NSLog(@"加载进度: %f", percent) ;
}
@end
