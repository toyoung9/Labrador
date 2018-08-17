//
//  ViewController.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "ViewController.h"
#import "LabradorAudioPlayer.h"
#import "LabradorCacheMapping.h"
#import "LabradorNetworkProvider.h"

@interface ViewController () <LabradorAudioPlayerDelegate>
{
    LabradorAudioPlayer *_player ;
    LabradorCacheMapping *_cache ;
    LabradorNetworkProvider *_networkProvider ;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor] ;
    _player = [[LabradorAudioPlayer alloc] init] ;
    _player.delegate = self ;

}


- (IBAction)play:(id)sender {
    [_player prepare] ;
}
- (IBAction)pause:(id)sender {
    [_player pause] ;
}
- (IBAction)resume:(id)sender {
    [_player resume] ;
}

- (void)sliderValueChanged:(UISlider *)slider {
    [_player seek:slider.value] ;
}

#pragma mark -
- (void)labradorAudioPlayerPrepared:(LabradorAudioPlayer *)player {
    NSLog(@"-------------labradorAudioPlayerPrepared") ;
    _slider.minimumValue = 0 ;
    _slider.maximumValue = player.duration ;
    [_player play] ;
}
- (void)labradorAudioPlayerWithError:(NSError *)error player:(LabradorAudioPlayer *)player {
    NSLog(@"发生错误: %@", error) ;
}
- (void)labradorAudioPlayerPlaying:(LabradorAudioPlayer *)player playTime:(float)playTime {
//    NSLog(@"播放时间: %f", playTime) ;
}
- (void)labradorAudioPlayerCachingPercent:(LabradorAudioPlayer *)player percent:(float)percent {
    NSLog(@"缓存百分比: %f", percent) ;
}

@end
