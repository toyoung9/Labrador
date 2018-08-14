//
//  ViewController.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "ViewController.h"
#import "LabradorAudioPlayer.h"
#import "LabradorCache.h"
#import "LabradorNetworkProvider.h"

@interface ViewController ()
{
    LabradorAudioPlayer *_player ;
    LabradorCache *_cache ;
    LabradorNetworkProvider *_networkProvider ;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor] ;
    _player = [[LabradorAudioPlayer alloc] init] ;
//
//    _cache = [[LabradorCache alloc] initWithURLString:@"zbdd.mp3"] ;
//    [_cache initializeLength:1024 * 1024 * 3] ;
    
//    [_cache downloadWithStart:1024 * 10 length:1024 * 30] ;
    
}


- (IBAction)play:(id)sender {
    [_player play] ;
//    NSRange range = [_cache findNextDownloadFragment] ;
//    NSLog(@"需要下载的片段: %@", NSStringFromRange(range)) ;
//    [_cache completedFragment:range.location * 1024 length:range.length * 1024] ;
//    NSString *url = @"http://audio01.dmhmusic.com/114_95_T10032761338_128_1_1_0_sdk-cpm/0103/M00/A6/A6/ChR45VnBNauAG7GrAF7Km_rq-5E822.mp3?xcode=e6442be07dd1442a30aa39a5152e92f8921d7e9" ;
//    _networkProvider = [[LabradorNetworkProvider alloc] initWithURLString:url] ;
}
- (IBAction)pause:(id)sender {
    [_player pause] ;
}
- (IBAction)resume:(id)sender {
    [_player resume] ;
}

@end
