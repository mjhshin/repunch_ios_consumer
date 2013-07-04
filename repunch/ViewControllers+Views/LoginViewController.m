//
//  LoginViewController.m
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

#import <Parse/Parse.h>

//TODO: ALLL THE FACEBOOK STUFF.

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [_usernameInput setDelegate:self];
    [_passwordInput setDelegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)login{
    //spinner to run while fetches happen
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 470);
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    [spinner startAnimating];
        
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"email", @"user_birthday", @"publish_actions"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [spinner stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            PFObject *patronObject = [user valueForKey:@"Patron"];
            [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
                NSLog(@"HERE?");
                
                //if patron doesn't exist (as in, if the user is trying to login without having previously registered, boo)
                if (fetchedPatronObject == nil){
                    FBRequest *request = [FBRequest requestForMe];
                    
                    NSLog(@"HOW ABOUT HERE?");
                    
                    // Send request to Facebook
                    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            // result is a dictionary with the user's Facebook data
                            NSDictionary *userData = (NSDictionary *)result;
                            NSString *facebookID = userData[@"id"];
                            NSString *fName = userData[@"first_name"];
                            NSString *lName = userData[@"last_name"];
                            NSString *email = userData[@"email"];
                            NSString *gender = userData[@"gender"];
                            NSString *birthday = userData[@"birthday"];
                            NSLog(@"AM I HERE YET?");
                            
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id", [[PFUser currentUser]username], @"username", email, @"email", gender, @"gender", fName, @"first_name", birthday, @"birthday", lName, @"last_name", facebookID, @"facebook_id", nil];
                            
                            [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                                if (!error){
                                    
                                    //make sure installation is set
                                    NSString *userPatronID = [createdPatronObject objectId];
                                    NSString *punch_code = [createdPatronObject valueForKey:@"punch_code"];
                                    [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
                                    [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
                                    [[PFInstallation currentInstallation] saveInBackground];
                                    
                                    User *localUserEntity = [User MR_createEntity];
                                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:createdPatronObject];
                                    NSLog(@"user is %@", localUserEntity);
                                    
                                    [appDelegate setLocalUser:localUserEntity];
                                    [appDelegate setPatronObject:createdPatronObject];
                                    
                                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                                }
                                else{
                                    NSLog(@"There was an ERROR: %@", error);
                                    
                                }
                            }]; //end register patron cloud code
                            
                            
                        }
                    }]; //end get user info
                    
                } //end if fetchedPatronObject is nil
                
                else{
                    //make sure installation is set
                    NSString *userPatronID = [fetchedPatronObject objectId];
                    NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
                    [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
                    [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
                    [[PFInstallation currentInstallation] saveInBackground];
                    
                    [appDelegate setPatronObject:fetchedPatronObject];
                    User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
                    if (localUserEntity == nil){
                        localUserEntity = [User MR_createEntity];
                    }
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
                    [appDelegate setLocalUser:localUserEntity];
                    
                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                }
            }];

        }
    }];

    

}

#pragma mark - Gesture methods

-(void)dismissKeyboard {
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];

}

#pragma mark - Button methods

- (IBAction)registerBtn:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    registerVC.modalDelegate = self;
    [self presentViewController:registerVC animated:YES completion:NULL];
}

- (IBAction)recoverpwdBtn:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Forgotten password?"
                          message:@"Enter your e-mail and we'll get on that in a jiffy."
                          delegate:self
                          cancelButtonTitle:@"Nevermind."
                          otherButtonTitles: @"Sweet.",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];

    
}


- (IBAction)signinBtn:(id)sender {
    if ([_usernameInput.text length] > 0 || [_passwordInput.text length] > 0){
        //spinner to run while fetches happen
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(160, 470);
        spinner.color = [UIColor blackColor];
        [self.view addSubview:spinner];
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

- (IBAction)fbLogin:(id)sender {
    UIAlertView *loginPrompt = [[UIAlertView alloc] initWithTitle:@"Login with Facebook" message:@"Please enter your login information" delegate:self cancelButtonTitle:@
                                "Cancel" otherButtonTitles:@"Login", nil];
    loginPrompt.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginPrompt show];
}

#pragma mark - Modal Delegate methods

- (void)didDismissPresentedViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Text View Delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex

{
    if (buttonIndex == 1)
    {
        
        if ([[alertView title] isEqualToString:@"Forgotten password?"]){
            NSString *email = [[alertView textFieldAtIndex:0] text];
            [PFUser requestPasswordResetForEmailInBackground:email];
        }
        if ([[alertView title] isEqualToString:@"Login with Facebook"]){
            
            [self login];

        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField   {
    [self dismissKeyboard];
    [self signinBtn:self];
    return YES;
}


@end
