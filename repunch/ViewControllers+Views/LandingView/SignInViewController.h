//
//  SignInViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SignInViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

- (IBAction)loginWithFB:(id)sender;
- (IBAction)loginWithEmail:(id)sender;
- (IBAction)getForgottenPassword:(id)sender;
@end
