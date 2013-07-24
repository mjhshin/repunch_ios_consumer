//
//  RegisterViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"
#import "ParseStore.h"
#import "AppDelegate.h"
#import "UIViewController+KNSemiModal.h"
#import "SIAlertView.h"


@implementation RegisterViewController{
    ParseStore *parseStore;
    UIActivityIndicatorView *spinner;
    UIDatePicker *datePicker;
    NSArray *pickerItems;
    UIPickerView *genderPicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    parseStore = [[ParseStore alloc] init];
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 100);
    spinner.color = [UIColor grayColor];
    [[self view] addSubview:spinner];

    CGRect contentRect = CGRectZero;
    for ( UIView *subview in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, subview.frame);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(contentRect)+10);
    _genderInput.delegate = self;
    _birthdayInput.delegate = self;
    
    pickerItems = @[@"female", @"male"];

}

-(void)viewWillDisappear:(BOOL)animated {
    [self dismissKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToPlaces)
                                                 name:@"finishedLoggingIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showError)
                                                 name:@"errorLoggingIn"
                                               object:nil];

    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoggingIn" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"errorLoggingIn" object:nil];
    
}

#pragma mark - notification center methods

-(void)goToPlaces{
    [spinner stopAnimating];
    [[self modalDelegate] didDismissPresentedViewControllerWithCompletion];
}

-(void)showError {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"There was an error."
                          message:@"Sorry, something went wrong."
                          delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles: nil];
    [alert show];
}



#pragma mark - registration methods

- (IBAction)registerWithFB:(id)sender
{
    [spinner startAnimating];
    [parseStore signUserWithFacebook];

}

- (IBAction)registerWithEmail:(id)sender {
    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
    NSString *email = [_emailInput text];
    
    [self dismissKeyboard];
    
    __block PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = email;
    [newUser setValue:@"patron" forKey:@"account_type"];
    
    //spinner to run while fetches happen
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 480);
    spinner.color = [UIColor blackColor];
    [[self view] addSubview:spinner];
    [spinner startAnimating];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            [spinner stopAnimating];
            NSString *username = [_usernameInput text];
            NSString *email = [_emailInput text];
            NSString *fName = [_firstNameInput text];
            NSString *lName = [_lastNameInput text];
            NSString *birthday = [_birthdayInput text];
            NSString *gender = [_genderInput text];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id",username, @"username", email, @"email", gender, @"gender", birthday, @"birthday", fName, @"first_name", lName, @"last_name", nil];
            
            [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                if (!error){
                    
                    User *localUserEntity = [User MR_createEntity];
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:createdPatronObject];
                    NSLog(@"user is %@", localUserEntity);
                    
                    [appDelegate setLocalUser:localUserEntity];
                    [appDelegate setPatronObject:createdPatronObject];
                                        
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate login];
                }
                else{
                    SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error" andMessage:@"Something went wrong."];
                    [errorDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
                    [errorDialogue show];

                    NSLog(@"There was an ERROR: %@", error.debugDescription);
                    
                }
            }]; //end cloud code for register patron
            
        }
        
        else{
            [spinner stopAnimating];
            SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error" andMessage:@"Something went wrong."];
            [errorDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
            [errorDialogue show];

            [PFUser logOut];
            NSLog(@"There was an ERROR: %@", error);
        }
    }]; //end sign up block

}


- (IBAction)cancelRegistration:(id)sender {
    NSLog(@"here");
    
    [[self modalDelegate] didDismissPresentedViewController];
}

#pragma mark - UI gesture methods

-(void)dismissKeyboard {
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_emailInput resignFirstResponder];
    [_genderInput resignFirstResponder];
    [_birthdayInput resignFirstResponder];
    
}

#pragma mark - Data validation methods

- (BOOL)validateForm
{
    NSMutableString *errMsg = [NSMutableString stringWithString:@""];
    
    if (_usernameInput.text.length <= 0) {
        [errMsg appendString:@"Username is required.\n"];
    }
    
    if (_passwordInput.text.length <= 0) {
        [errMsg appendString:@"Password is required.\n"];
    }
    
    if (_emailInput.text.length <= 0) {
        [errMsg appendString:@"Email is required.\n"];
        
    } else if (![self validateEmail:_emailInput.text]) {
        [errMsg appendString:@"Invalid email address.\n"];
    }
    
    if (_birthdayInput.text.length <=0){
        [errMsg appendString:@"Birthday is required.\n"];
    }
    if (_genderInput.text.length <=0)
    {
        [errMsg appendString:@"Gender is required.\n"];
    }
    if (!([_genderInput.text isEqualToString:@"male"] || [_genderInput.text isEqualToString:@"female"]))
    {
        [errMsg appendString:@"Please enter 'male' or 'female'.\n"];
    }
    if (errMsg.length > 0) {
        [_registerBtn setUserInteractionEnabled:NO];
        return NO;
    }
    
    return YES;
}
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag==11){
        datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(dateChanged)
         forControlEvents:UIControlEventValueChanged];


        textField.inputView = datePicker;
    }
    
    if (textField.tag==10){
        genderPicker = [[UIPickerView alloc] init];
        genderPicker.dataSource = self;
        genderPicker.delegate = self;
        genderPicker.showsSelectionIndicator = YES;
        
        textField.inputView = genderPicker;

    }
    return YES;

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag==11){
        _birthdayInput.text = [self ConvertedNSStringFromNSDate:[datePicker date]];

    }
    
    if (textField.tag==10){
        _genderInput.text = [pickerItems objectAtIndex:[genderPicker selectedRowInComponent:0]];
        
    }

}

-(void)dateChanged {
    _birthdayInput.text = [self ConvertedNSStringFromNSDate:[datePicker date]];
}


-(NSDate *)ConvertedNSDateFromNSString:(NSString *)inputString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:inputString];
    
    return dateFromString;
}

-(NSString *)ConvertedNSStringFromNSDate:(NSDate *)inputDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return strDate;
}*/


#pragma mark - Picker Methods -
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerItems.count;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerItems objectAtIndex:row];
}
@end
