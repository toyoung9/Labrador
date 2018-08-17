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

#pragma mark -
- (void)labradorAudioPlayerPrepared:(LabradorAudioPlayer *)player {
    NSLog(@"-------------labradorAudioPlayerPrepared") ;
    [_player play] ;
}
- (void)labradorAudioPlayerWithError:(NSError *)error player:(LabradorAudioPlayer *)player {
    NSLog(@"发生错误: %@", error) ;
}
@end
