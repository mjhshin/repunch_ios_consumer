//
//  RegisterViewController.h
//  repunch
//
//  Created by CambioLabs on 5/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    UIScrollView *scrollView;
    UITextField *activeField;
    CustomTextField *usernameTextField;
    CustomTextField *passwordTextField;
    CustomTextField *password2TextField;
    CustomTextField *emailTextField;
    CustomTextField *birthdayTextField;
    CustomTextField *genderTextField;
    UIDatePicker *datePicker;
    UIToolbar *dateDoneView;
    UIPickerView *genderPicker;
    UIToolbar *genderDoneView;
    NSArray *genderOptions;
}

@property (nonatomic, retain) UIScrollView *scrollview;
@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic, retain) CustomTextField *usernameTextField;
@property (nonatomic, retain) CustomTextField *passwordTextField;
@property (nonatomic, retain) CustomTextField *password2TextField;
@property (nonatomic, retain) CustomTextField *emailTextField;
@property (nonatomic, retain) CustomTextField *birthdayTextField;
@property (nonatomic, retain) CustomTextField *genderTextField;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIToolbar *dateDoneView;
@property (nonatomic, retain) UIPickerView *genderPicker;
@property (nonatomic, retain) UIToolbar *genderDoneView;
@property (nonatomic, retain) NSArray *genderOptions;

@end
