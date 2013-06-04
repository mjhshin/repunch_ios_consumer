//
//  LoginViewController.m
//  repunch
//
//  Created by CambioLabs on 4/8/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomButton.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField, activeField, scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"splash"]]];
    [self registerForKeyboardNotifications];
    
    scrollView = [[[UIScrollView alloc] initWithFrame:self.view.frame] autorelease];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * .75)];
    [self.view addSubview:scrollView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repunch"]];
    [logoImageView setCenter:CGPointMake(self.view.frame.size.width / 2, 20)];
    [scrollView addSubview:logoImageView];
    
    UIImage *fbImage = [UIImage imageNamed:@"login-button-small"];
    UIButton *fbLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fbLoginButton addTarget:self action:@selector(fbLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbLoginButton setFrame:CGRectMake(self.view.frame.size.width / 2 - fbImage.size.width / 2, logoImageView.frame.origin.y + logoImageView.frame.size.height + 10, fbImage.size.width, fbImage.size.height)];
    [fbLoginButton setImage:fbImage forState:UIControlStateNormal];
    [fbLoginButton setImage:[UIImage imageNamed:@"login-button-small-pressed"] forState:UIControlStateHighlighted];
    [fbLoginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [fbLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fbLoginButton setTitleEdgeInsets:UIEdgeInsetsMake(0,-fbImage.size.width + 40,0,0)];
    [fbLoginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [scrollView addSubview:fbLoginButton];
    
    UILabel *label1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, fbLoginButton.frame.origin.y + fbLoginButton.frame.size.height + 40, self.view.frame.size.width, 40)] autorelease];
    [label1 setText:@"Or sign in with your Repunch account"];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setFont:[UIFont systemFontOfSize:13]];
    [label1 sizeToFit];
    [label1 setCenter:CGPointMake(self.view.frame.size.width / 2, label1.frame.origin.y + label1.frame.size.height / 2)];
    [scrollView addSubview:label1];
    
    usernameTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, label1.frame.origin.y + label1.frame.size.height + 20, 255, 40)];
    [usernameTextField setPlaceholder:@"Username"];
    [usernameTextField setDelegate:self];
    [usernameTextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:usernameTextField];
    
    passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, usernameTextField.frame.origin.y + usernameTextField.frame.size.height + 10, 255, 40)];
    [passwordTextField setPlaceholder:@"Password"];
    [passwordTextField setDelegate:self];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setReturnKeyType:UIReturnKeyDone];
    [scrollView addSubview:passwordTextField];
    
    UIImage *loginImage = [UIImage imageNamed:@"btn-signin"];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(loginUser) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setFrame:CGRectMake(self.view.frame.size.width / 2 - loginImage.size.width / 2, passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 10, loginImage.size.width, loginImage.size.height)];
    [loginButton setImage:loginImage forState:UIControlStateNormal];
    [scrollView addSubview:loginButton];
    
    CustomButton *forgotButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [forgotButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 90, loginButton.frame.origin.y + loginButton.frame.size.height + 10, 180, 20)];
    [forgotButton addTarget:self action:@selector(forgot) forControlEvents:UIControlEventTouchUpInside];
    [forgotButton setTitle:@"I forgot my password" forState:UIControlStateNormal];
    [forgotButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [scrollView addSubview:forgotButton];
    
    CustomButton *cancelButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 30, forgotButton.frame.origin.y + forgotButton.frame.size.height + 10, 60, 20)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [scrollView addSubview:cancelButton];
    
}

- (void)forgot
{

}

- (void)cancel
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LandingViewController *landingVC = [[LandingViewController alloc] init];
    ad.lvc = landingVC;
    ad.window.rootViewController = ad.lvc;
}

- (void)loginUser
{
    [PFUser logInWithUsernameInBackground:usernameTextField.text password:passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {

            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_findFirstByAttribute:@"username" withValue:user.username];
            if (localUser == nil) {
                localUser = [User MR_createInContext:localContext];
            }
            [localUser setFromParse:user];
            [localContext MR_saveToPersistentStoreAndWait];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
            [appDelegate.placesvc loadPlaces];
            
        } else {
            // The login failed. Check error to see why.
            if (error.code == 101) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Invalid login credentials" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [av show];
            }
        }
    }];
}

- (void)fbLogin
{
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            if (error) {
                NSLog(@"signup error: %@",error);
            }
            
            [self setUserFromFacebook:YES];
        } else {
            NSLog(@"User with facebook logged in!");
            if (error) {
                NSLog(@"login error: %@",error);
            }
            
            [self setUserFromFacebook:NO];
        }
    }];
}

- (void)setUserFromFacebook:(BOOL)userIsNew
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            PFUser *user = [PFUser currentUser];
            user.email = [userData objectForKey:@"email"];
            [user setObject:[userData objectForKey:@"gender"] forKey:@"gender"];
            [user setObject:[userData objectForKey:@"birthday"] forKey:@"birth_date"];
            [user setObject:[userData objectForKey:@"first_name"] forKey:@"first_name"];
            [user setObject:[userData objectForKey:@"last_name"] forKey:@"last_name"];
            [user setObject:[userData objectForKey:@"id"] forKey:@"facebook_id"];

            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_findFirstByAttribute:@"email" withValue:[user objectForKey:@"email"]];
            if (localUser == nil) {
                localUser = [User MR_createInContext:localContext];
            }
            [localUser setFromParse:user];
            [localContext MR_saveToPersistentStoreAndWait];
            
//            if (userIsNew) {
//                PFQuery *existinguserquery = [PFUser query];
//                [existinguserquery whereKey:@"email" equalTo:[user objectForKey:@"email"]];
//                
//                [existinguserquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//                    if (error) {
//                        NSLog(@"error checking for existing user");
//                    } else {
//                        // if user exists and not linked, then link 'em
//                        PFUser *existinguser = [objects objectAtIndex:0];
//                        [PFUser logInWithUsernameInBackground:existinguser.username password:existinguser.password block:^(PFUser *user, NSError *error){
//                            if (error) {
//                                NSLog(@"error logging in existing user: %@", error);
//                            } else {
//                                if (![PFFacebookUtils isLinkedWithUser:existinguser]) {
//                                    [PFFacebookUtils linkUser:existinguser permissions:@[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"] block:^(BOOL succeeded, NSError *error){
//                                        if (error) {
//                                            NSLog(@"error linking to facebook: %@",error);
//                                        } else {
//                                            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//                                                if (error != nil) {
//                                                    NSLog(@"PFUser save error - fb callback: %@",[error description]);
//                                                } else {
//                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                                                    [appDelegate.placesvc loadPlaces];
//                                                }
//                                            }];
//                                        }
//                                    }];
//                                }
//                            }
//                        }];
//                    }
//                }];
//            } else {
            
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (error != nil) {
                        NSLog(@"PFUser save error - fb callback: %@",[error description]);
                        if (error.code == 203) {
                            // email already exists
                            UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Email Already Exists" message:@"There is already an account with the provided email. Please log in with your existing Repunch account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
                            [av show];
                            
                            [user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                if (error) {
                                    NSLog(@"error deleting new pointless user: %@",error);
                                }
                            }];
                        }
                    } else {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                        [appDelegate.window setRootViewController:appDelegate.tabBarController];                        
                        [appDelegate.placesvc loadPlaces];
                    }
                }];
//            }
            
        } else {
            NSLog(@"fb error: %@",error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard adjustments

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameTextField) {
        [passwordTextField becomeFirstResponder];
    } else if(textField == passwordTextField) {
        [passwordTextField resignFirstResponder];
    }
    
    return YES;
}

@end
