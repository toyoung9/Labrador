//
//  ViewController.m
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import "ViewController.h"
#import "LabradorLocalProvider.h"
#import "LabradorDataProviderProtocol.h"
#import "LabradorAFSParser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    id<LabradorDataProviderProtocol> provider = [[LabradorLocalProvider alloc] init] ;
    id<LabradorParseProtocol> parser = [[LabradorAFSParser alloc] init:provider] ;
    AudioStreamBasicDescription bd = [parser parse] ;
    
    NSLog(@"...") ;
}


@end
