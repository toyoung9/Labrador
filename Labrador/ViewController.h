//
//  ViewController.h
//  Labrador
//
//  Created by legendry on 2018/8/6.
//  Copyright © 2018 legendry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong)IBOutlet UISlider *slider ;

- (IBAction)play:(id)sender ;
- (IBAction)pause:(id)sender ;
- (IBAction)resume:(id)sender ;
- (IBAction)sliderValueChanged:(UISlider *)slider ;
@end

