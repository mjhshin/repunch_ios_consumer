//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)cancelLogin:(id)sender;
- (IBAction)loginWithFB:(id)sender;
- (IBAction)loginWithEmail:(id)sender;
- (IBAction)getForgottenPassword:(id)sender;

@end
