//
//  ViewController.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "ViewController.h"
#import "LabradorAudioPlayer.h"

@interface ViewController ()
{
    LabradorAudioPlayer *_player ;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor] ;
    _player = [[LabradorAudioPlayer alloc] init] ;
}


- (IBAction)play:(id)sender {
    [_player play] ;
}
- (IBAction)pause:(id)sender {
    [_player pause] ;
}
- (IBAction)resume:(id)sender {
    [_player resume] ;
}

@end
