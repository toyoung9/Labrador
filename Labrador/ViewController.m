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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _player = [[LabradorAudioPlayer alloc] init] ;
}

@end
