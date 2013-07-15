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


@implementation RegisterViewController{
    ParseStore *parseStore;
    UIActivityIndicatorView *spinner;
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
    [parseStore registerUserWithFacebook];

}

- (IBAction)registerWithEmail:(id)sender {
    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
    NSString *email = [_emailInput text];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[_firstNameInput text], @"fName", [_lastNameInput text], @"lName", @"01/01/1991", @"birthday", [_genderInput text], @"gender", nil];
    [self dismissKeyboard];
    
    [spinner startAnimating];
    [parseStore registerUserInWithUsername:username andPassword:password andEmail:email andUserInfoDictionary:userInfo];
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
    if (errMsg.length > 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration Error" message:errMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [av show];
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



@end
