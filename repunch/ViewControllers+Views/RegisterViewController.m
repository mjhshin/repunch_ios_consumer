//
//  RegisterViewController.m
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"


//TODO: TEST THIS WORKS.
//TODO: ALLLL THE FACEBOOK STUFF.
//TODO: NSDATE

@implementation RegisterViewController

#pragma mark - setup methods
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    CGRect contentRect = CGRectZero;
    for ( UIView *subview in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, subview.frame);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(contentRect)+10);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerWithEmail{
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
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
            NSString *birthday = @"01/01/1991";
            NSString *gender = [_genderInput text];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id",username, @"username", email, @"email", gender, @"gender", fName, @"first_name", lName, @"last_name", nil];
            
            [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                if (!error){
                    
                    User *localUserEntity = [User MR_createEntity];
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:createdPatronObject];
                    NSLog(@"user is %@", localUserEntity);
                    
                    [appDelegate setLocalUser:localUserEntity];
                    [appDelegate setPatronObject:createdPatronObject];
                    
                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                }
                else{
                    NSLog(@"There was an ERROR: %@", error);
                    
                }
            }]; //end cloud code for register patron

        }
        
        else{
            [spinner stopAnimating];
            NSLog(@"There was an ERROR: %@", error);
        }
    }]; //end sign up block
    
}


-(void)registerWithFacebook{
    
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

#pragma mark - UI response methods

- (IBAction)registerBtn:(id)sender {
    if (![self validateForm]) {
        return;
    }
    
    [self registerWithEmail];
}

- (IBAction)cancelBtn:(id)sender {
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

 - (IBAction)fbRegisterBtn:(id)sender {
     
     UIAlertView *loginPrompt = [[UIAlertView alloc] initWithTitle:@"Login with Facebook" message:@"Please enter your login information" delegate:self cancelButtonTitle:@
                                 "Cancel" otherButtonTitles:@"Login", nil];
     loginPrompt.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
     [loginPrompt show];
      
}

#pragma mark - Text View Delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex

{
    if (buttonIndex == 1)
    {
        if ([[alertView title] isEqualToString:@"Login with Facebook"]){
            //spinner to run while fetches happen
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.center = CGPointMake(160, 470);
            spinner.color = [UIColor blackColor];
            [self.view addSubview:spinner];
            
            [self registerWithFacebook];
        }
    }
}

@end
