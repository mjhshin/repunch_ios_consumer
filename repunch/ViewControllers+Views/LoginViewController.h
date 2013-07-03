//
//  LoginViewController.h
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface LoginViewController : UIViewController <ModalDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
- (IBAction)signinBtn:(id)sender;
- (IBAction)registerBtn:(id)sender;
- (IBAction)recoverpwdBtn:(id)sender;
- (IBAction)fbLogin:(id)sender;

@end
