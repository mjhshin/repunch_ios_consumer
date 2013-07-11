//
//  RegisterViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UITextField *firstNameInput;
@property (weak, nonatomic) IBOutlet UITextField *lastNameInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *genderInput;
@property (weak, nonatomic) IBOutlet UITextField *birthdayInput;

- (IBAction)registerWithFB:(id)sender;
- (IBAction)registerWithEmail:(id)sender;

@end
