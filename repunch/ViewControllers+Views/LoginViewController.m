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

@implementation LoginViewController{
    UIActivityIndicatorView *spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [_usernameInput setDelegate:self];
    [_passwordInput setDelegate:self];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 470);
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)login{
    
    //check make sure device store_id matches the store_id of employee logging in
    NSString *devicePatronID = [[PFInstallation currentInstallation] objectForKey:@"patron_id"];
    NSLog(@"device patron ID is: %@", devicePatronID);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PFObject *patronObject = [[PFUser currentUser] valueForKey:@"Patron"];
    [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
        
        //check make sure device store_id matches the store_id of employee logging in
        NSString *userPatronID = [fetchedPatronObject objectId];
        NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
        if (![devicePatronID isEqualToString:userPatronID]){
            [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
            [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
            [[PFInstallation currentInstallation] saveInBackground];
            NSLog(@"device patron ID is now: %@", [[PFInstallation currentInstallation] objectForKey:@"patron_id"]);
        }
        
        [appDelegate setPatronObject:fetchedPatronObject];
        User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
        if (localUserEntity == nil){
            localUserEntity = [User MR_createEntity];
        }
        [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
        [appDelegate setLocalUser:localUserEntity];
        
        [appDelegate.window setRootViewController:appDelegate.tabBarController];
    }];
    
}


-(void)loginWithFacebook{
    [spinner startAnimating];
        
    NSArray *permissionsArray = @[@"email", @"user_birthday", @"publish_actions"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            [spinner stopAnimating];
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (error){
            [spinner stopAnimating];

        }
        else {
            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //[appDelegate.window setRootViewController:appDelegate.tabBarController];

            PFObject *patronObject = [user objectForKey:@"Patron"];
            if (patronObject == nil){
                [self registerWithFacebook];
            }

            [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
                
                if (!error){

                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                    //set app delegate local user + patron object
                    User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
                    if (localUserEntity == nil){
                        localUserEntity = [User MR_createEntity];
                    }
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
                    [appDelegate setLocalUser:localUserEntity];
                    [appDelegate setPatronObject:fetchedPatronObject];
                    
                    //make sure installation is set
                    NSString *userPatronID = [fetchedPatronObject objectId];
                    NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
                    [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
                    [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
                    [[PFInstallation currentInstallation] saveInBackground];
                    
                    
                    [spinner stopAnimating];
                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                }
                else if (error){
                    NSLog(@"Error is %@", error);
                }
            
            }];
        }
    }];


}

-(void)registerWithFacebook{
    
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
            FBRequest *request = [FBRequest requestForMe];
            
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
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id", [[PFUser currentUser]username], @"username", email, @"email", gender, @"gender", fName, @"first_name", birthday, @"birthday", lName, @"last_name", facebookID, @"facebook_id", nil];
                    
                    [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                        if (!error){
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
            
        }
    }]; //end login with facebook user
    
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
    [self loginWithFacebook];
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
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField   {
    [self dismissKeyboard];
    [self signinBtn:self];
    return YES;
}


@end
