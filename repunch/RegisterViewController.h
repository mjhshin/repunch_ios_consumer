//
//  RegisterViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import <AVFoundation/AVFoundation.h>
#import "AuthenticationManager.h"

@interface RegisterViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate, AuthenticationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *ageInput;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSelector;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookSpinner;
@property (weak, nonatomic) IBOutlet UILabel *facebookButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)registerWithFacebook:(id)sender;
- (IBAction)registerWithRepunch:(id)sender;

@end
