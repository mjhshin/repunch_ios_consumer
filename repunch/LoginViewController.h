//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPButton.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet RPButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *facebookButtonLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookSpinner;

- (IBAction)loginWithRepunch:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
