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
                        NSLog(@"device store ID is now: %@", [[PFInstallation currentInstallation] objectForKey:@"patron_id"]);
                    }

                    [appDelegate setPatronObject:fetchedPatronObject];
                    User *localUserEntity = [User MR_createEntity];
                    [localUserEntity setFromParseUserObject:user andPatronObject:fetchedPatronObject];
                    [appDelegate setLocalUser:localUserEntity];

                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                    


                }];
                

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
        NSString *email = [[alertView textFieldAtIndex:0] text];
        [PFUser requestPasswordResetForEmailInBackground:email];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField   {
    [self dismissKeyboard];
    [self signinBtn:self];
    return YES;
}


@end
