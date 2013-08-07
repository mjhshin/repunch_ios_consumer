//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "DataManager.h"

@implementation LoginViewController
{
    DataManager* sharedData;
    UIActivityIndicatorView *spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [DataManager getSharedInstance];
    
    //gesture to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	//self.navigationController.navigationBarHidden = NO;
	//self.navigationItem.title = @"Login";
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.view.bounds;
	[self.view.layer insertSublayer:bgLayer atIndex:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField shiftScreenUp:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField shiftScreenUp:NO];
}

- (void) animateTextField: (UITextField*)textField shiftScreenUp:(BOOL)up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
	
    int movement = (up ? -movementDistance : movementDistance);
	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	if(textField == _usernameInput) {
		[_usernameInput resignFirstResponder];
		[_passwordInput becomeFirstResponder];
		
	} else if(textField == _passwordInput) {
		[_passwordInput resignFirstResponder];		
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)loginWithEmail:(id)sender
{
	[self dismissKeyboard];
	
	NSString *username = [_usernameInput text];
	NSString *password = [_passwordInput text];
	
	if(username.length == 0) {
		[self showDialog:@"Please enter your username" withResultMessage:nil];
		return;
		
	} else if(password.length == 0) {
		[self showDialog:@"Please enter your password" withResultMessage:nil];
		return;
	}
	
	//[spinner startAnimating];
        
	[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
		//[spinner stopAnimating];
		if (user) {
			NSString *accountType = [user objectForKey:@"account_type"];
			
			if( [accountType isEqualToString:@"patron"] ) {
				NSString *patronId = [[user objectForKey:@"Patron"] objectId];
				[self fetchPatronPFObject:patronId];
				
			} else {
				NSLog(@"Account exists but is not of type 'patron'");
				[PFUser logOut];
				[self showDialog:@"Login Failed" withResultMessage:@"Please check your username/password"];
			}
                
		} else {
			[self showDialog:@"Login Failed" withResultMessage:@"Please check your username/password"];
			NSLog(@"Here is the ERROR: %@", error);
		}
	}]; //end get user block
}

- (void)fetchPatronPFObject:(NSString*)patronId
{	
	PFQuery *query = [PFQuery queryWithClassName:@"Patron"];
	
	[query getObjectInBackgroundWithId:patronId block:^(PFObject *patron, NSError *error)
	{
		//[spinner stopAnimating];
		
		if(!error) {
			NSLog(@"Fetched Patron object: %@", patron);
			
			[sharedData setPatron:patron];
			
			//setup PFInstallation
			NSString *patronId = [patron objectId];
			NSString *punchCode = [patron objectForKey:@"punch_code"];
			[self setupPFInstallation:patronId withPunchCode:punchCode];
			
		} else {
			[self showDialog:@"Login Failed" withResultMessage:@"Sorry, something went wrong"];
			[PFUser logOut];
		}
	}];
}

- (void)setupPFInstallation:(NSString*)patronId withPunchCode:(NSString*)punchCode
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[[PFInstallation currentInstallation] setObject:patronId forKey:@"patron_id"];
	[[PFInstallation currentInstallation] setObject:punchCode forKey:@"punch_code"];
	[[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		//[spinner stopAnimating];
		
		if(!error) {
			//login complete
			[appDelegate presentTabBarController];
			
		} else {
			[self showDialog:@"Login Failed" withResultMessage:@"Sorry, something went wrong"];
			[PFUser logOut];
		}
	}];
}

- (IBAction)getForgottenPassword:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?"
													message:@"Enter your email address and we'll help you reset your password."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


- (IBAction)cancelLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginWithFB:(id)sender
{
    [spinner startAnimating];
}

- (void)dismissKeyboard
{
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
}

- (void)showDialog:(NSString*)resultTitle withResultMessage:(NSString*)resultMessage
{
	[[[UIAlertView alloc] initWithTitle:resultTitle
								message:resultMessage
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles: nil] show];
}

@end
