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

#pragma mark - login methods
- (IBAction)loginWithEmail:(id)sender {
    if ([_usernameInput.text length] > 0 || [_passwordInput.text length] > 0){
        [spinner startAnimating];
        
        [PFUser logInWithUsernameInBackground:[_usernameInput text] password:[_passwordInput text] block:^(PFUser *user, NSError *error){
            if (user){
                [spinner stopAnimating];
                
                //dismiss keyboard on sign in
                [_usernameInput resignFirstResponder];
                [_passwordInput resignFirstResponder];
                
                [self login];
                
            }
            else {
                [spinner stopAnimating];
                [[[UIAlertView alloc] initWithTitle:@"Invalid login" message:@"Didn't find any user with that login" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                NSLog(@"Here is the ERROR: %@", error);
            }
        }]; //end get user block
        
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Empty..." message:@"You didn't fill out both fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
    }
}

-(void)login{
    
    //check make sure device store_id matches the store_id of employee logging in
    NSString *devicePatronID = [[PFInstallation currentInstallation] objectForKey:@"patron_id"];
    NSLog(@"device patron ID is: %@", devicePatronID);
    NSLog(@"device punch_code is: %@", [[PFInstallation currentInstallation] objectForKey:@"punch_code"]);

    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PFObject *patronObject = [[PFUser currentUser] valueForKey:@"Patron"];
    [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
        
        //check make sure device store_id matches the store_id of employee logging in
        NSString *userPatronID = [fetchedPatronObject objectId];
        NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
        if (![devicePatronID isEqualToString:userPatronID]){
            [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
            [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
            [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"device patron ID is now: %@", [[PFInstallation currentInstallation] objectForKey:@"patron_id"]);
                NSLog(@"device punch_code is now: %@", [[PFInstallation currentInstallation] objectForKey:@"punch_code"]);

                if (!error){
                    [appDelegate setPatronObject:fetchedPatronObject];
                    User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
                    if (localUserEntity == nil){
                        localUserEntity = [User MR_createEntity];
                    }
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
                    [appDelegate setLocalUser:localUserEntity];
                    
                    [appDelegate login];
                }
                else {
                    [PFUser logOut];
                    NSLog(@"%@", error);
                }

            }];

        }
        else {
            [appDelegate setPatronObject:fetchedPatronObject];
            User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
            if (localUserEntity == nil){
                localUserEntity = [User MR_createEntity];
            }
            [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
            [appDelegate setLocalUser:localUserEntity];
            
            [appDelegate login];

        }
        
    }];
    
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


- (IBAction)closeView:(id)sender {
    [[self modalDelegate] didDismissPresentedViewController];
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
