//
//  RegisterViewController.h
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *birthdayInput;
@property (weak, nonatomic) IBOutlet UITextField *genderInput;

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

- (IBAction)registerBtn:(id)sender;
- (IBAction)cancelBtn:(id)sender;

@end
