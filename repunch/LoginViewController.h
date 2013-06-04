//
//  LoginViewController.h
//  repunch
//
//  Created by CambioLabs on 4/8/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>{
    UIScrollView *scrollView;
    UITextField *activeField;
    CustomTextField *usernameTextField;
    CustomTextField *passwordTextField;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic, retain) CustomTextField *usernameTextField;
@property (nonatomic, retain) CustomTextField *passwordTextField;

@end
