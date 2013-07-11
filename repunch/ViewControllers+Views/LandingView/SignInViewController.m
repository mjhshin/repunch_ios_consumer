//
//  SignInViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SignInViewController.h"
#import "ParseStore.h"
#import "AppDelegate.h"

@implementation SignInViewController {
    ParseStore *parseStore;
    UIActivityIndicatorView *spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //gesture to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    parseStore = [[ParseStore alloc] init];
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 100);
    spinner.color = [UIColor grayColor];
    [[self view] addSubview:spinner];



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

-(void)goToPlaces {
    [spinner stopAnimating];
    
    //go to saved places view
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setRootViewController:appDelegate.tabBarController];

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

#pragma mark - login methods
- (IBAction)loginWithEmail:(id)sender {
    
    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
    [parseStore signUserInWithUsername:username andPassword:password];
}

- (IBAction)getForgottenPassword:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Forgot your password?"
                          message:@"Enter your e-mail and we'll send instructions to fix that."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles: @"Okay",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


- (IBAction)loginWithFB:(id)sender {
    [spinner startAnimating];
    [parseStore signUserWithFacebook];
}

#pragma mark - gesture methods

-(void)dismissKeyboard {
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
}
@end
