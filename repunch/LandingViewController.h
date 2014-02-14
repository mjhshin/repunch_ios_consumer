//
//  LandingViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPButton.h"

@interface LandingViewController : UIViewController

@property (weak, nonatomic) IBOutlet RPButton *loginButton;
@property (weak, nonatomic) IBOutlet RPButton *registerButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;

- (IBAction)registerButtonPress:(id)sender;
- (IBAction)loginButtonPress:(id)sender;

@end
