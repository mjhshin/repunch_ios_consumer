
//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController
{
    DataManager *sharedData;
	AuthenticationManager *authenticationManager;
	UIActivityIndicatorView *loginButtonSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [DataManager getSharedInstance];
	authenticationManager = [AuthenticationManager getSharedInstance];
    
    //gesture to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	
	authenticationManager.delegate = self;
	
	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.title = @"Sign In";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.loginButton]
								   forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.loginButton]
								   forState:UIControlStateHighlighted];
	[self.loginButton.layer setCornerRadius:5];
	[self.loginButton setClipsToBounds:YES];
	
	loginButtonSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	loginButtonSpinner.frame = self.loginButton.bounds;
	loginButtonSpinner.hidesWhenStopped = YES;
	[self.loginButton addSubview:loginButtonSpinner];
	self.facebookSpinner.hidesWhenStopped = YES;
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if(textField == _emailInput) {
		[_emailInput resignFirstResponder];
		[_passwordInput becomeFirstResponder];
	}
	else if(textField == _passwordInput) {
		[self loginWithRepunch:self];
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)loginWithRepunch:(id)sender
{
	[self dismissKeyboard];
	
	NSString *email = [_emailInput text];
	NSString *password = [_passwordInput text];
	
	if(email.length == 0) {
		[self showDialog:@"Please enter your email" withResultMessage:nil];
		return;
		
	} else if(password.length == 0) {
		[self showDialog:@"Please enter your password" withResultMessage:nil];
		return;
	}
	
	[self.loginButton setTitle:@"" forState:UIControlStateNormal];
	[self.loginButton setEnabled:NO];
	[self.facebookButton setEnabled:NO];
	[loginButtonSpinner startAnimating];
        
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error)
	{
		if (user)
		{
			PFObject *patronObject = [user objectForKey:@"Patron"];
			
			if(patronObject == (id)[NSNull null] || patronObject == nil)
			{
				NSLog(@"Account exists but has Patron is null");
				[self handleError:nil withTitle:@"Login Failed" andMessage:@"Please check your username/password"];
			}
			else
			{
				NSString *patronId = [[user objectForKey:@"Patron"] objectId];
				[self fetchPatronPFObject:patronId];
			}
		}
		else
		{
			int errorCode = [[[error userInfo] objectForKey:@"code"] intValue];
			if(errorCode == kPFErrorObjectNotFound || errorCode == kPFErrorUserWithEmailNotFound)
			{
				[self handleError:nil withTitle:@"Login Failed" andMessage:@"Please check your username/password"];
			}
			else
			{
				[self handleError:nil
						withTitle:@"Login Failed"
					   andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
			}
		}
	}]; //end get user block
}

- (void)fetchPatronPFObject:(NSString*)patronId
{
	if(patronId == (id)[NSNull null] || patronId == nil) {
		[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
	}
	
	PFQuery *query = [PFQuery queryWithClassName:@"Patron"];
	
	[query getObjectInBackgroundWithId:patronId block:^(PFObject *patron, NSError *error) 
	{
		if(!error) {
			NSLog(@"Fetched Patron object: %@", patron);
			
			[sharedData setPatron:patron];
			
			//setup PFInstallation
			NSString *patronId = [patron objectId];
			NSString *punchCode = [patron objectForKey:@"punch_code"];
			[self setupPFInstallation:patronId withPunchCode:punchCode];
			
		} else {
			[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
		}
	}];
}

- (void)setupPFInstallation:(NSString*)patronId withPunchCode:(NSString*)punchCode
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[[PFInstallation currentInstallation] setObject:patronId forKey:@"patron_id"];
	[[PFInstallation currentInstallation] setObject:punchCode forKey:@"punch_code"];
	[[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		[loginButtonSpinner stopAnimating];
		[self.facebookSpinner stopAnimating];
		[self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
		[self.loginButton setEnabled:YES];
		[self.facebookButton setEnabled:YES];
		[self.facebookButtonLabel setHidden:NO];
		
		if(!error) {
			//login complete
			[appDelegate presentTabBarController];
			
		} else {
			[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
		}
	}];
}

- (IBAction)loginWithFacebook:(id)sender
{
	[self.loginButton setEnabled:NO];
	[self.facebookButton setEnabled:NO];
	[self.facebookSpinner startAnimating];
	[self.facebookButtonLabel setHidden:YES];
	
	[authenticationManager facebookLogin];
}

- (void)dismissKeyboard
{
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}

- (void)handleError:(NSError *)error withTitle:(NSString *)title andMessage:(NSString *)message
{
	NSLog(@"Here is the ERROR: %@", error);
	
	if([PFUser currentUser]) {
		[PFUser logOut];
	}
	
	[self showDialog:title withResultMessage:message];
	
	[loginButtonSpinner stopAnimating];
	[self.facebookSpinner stopAnimating];
	[self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.loginButton setEnabled:YES];
	[self.facebookButtonLabel setHidden:NO];
	[self.facebookButton setEnabled:YES];
}

- (void)onAuthenticationResult:(AuthenticationManager *)object withResult:(BOOL)success withError:(NSError *)error
{
	[loginButtonSpinner stopAnimating];
	[self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.loginButton setEnabled:YES];
	[self.facebookSpinner stopAnimating];
	[self.facebookButtonLabel setHidden:NO];
	[self.facebookButton setEnabled:YES];
	
	if(success)
	{
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate presentTabBarController];
	}
	else
	{
		NSLog(@"Here is the ERROR: %@", error);
		
		if([PFUser currentUser]) {
			[PFUser logOut];
		}
		
		//[self showDialog:title withResultMessage:message];
	}
}

- (void)showDialog:(NSString*)resultTitle withResultMessage:(NSString*)resultMessage
{
	NSString *capitalisedSentence =
		[resultMessage stringByReplacingCharactersInRange:NSMakeRange(0,1)
											   withString:[[resultMessage  substringToIndex:1] capitalizedString]];
	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:resultTitle
                                                 andMessage:capitalisedSentence];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

- (IBAction)forgotPassword:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?"
													message:@"Enter your email address and we'll help you reset your password."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(!alertView) {
		return;
	}
	
    if (buttonIndex == 1) {
        NSString *email = [[alertView textFieldAtIndex:0] text];
		
		if(email.length == 0) {
			return;
		}
		
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error)
		{
			NSString *titleString;
			NSString *messageString;
			
			if(!error)
			{
				titleString = @"Success!";
				messageString = @"Instructions to reset your password have been sent to your email";
			}
			else
			{
				titleString = @"Error";
				int errorCode = [[[error userInfo] objectForKey:@"code"] intValue];
				if(errorCode == kPFErrorInvalidEmailAddress) {
					messageString = [[error userInfo] objectForKey:@"error"];
				} else if(errorCode == kPFErrorUserWithEmailNotFound) {
					messageString = [[error userInfo] objectForKey:@"error"];
				} else {
					messageString = @"There was a problem connecting to Repunch. Please check your connection and try again.";
				}
			}
			
			NSString *capitalisedSentence =
			[messageString stringByReplacingCharactersInRange:NSMakeRange(0,1)
												   withString:[[messageString  substringToIndex:1] capitalizedString]];
			
			SIAlertView *alert = [[SIAlertView alloc] initWithTitle:titleString
														 andMessage:capitalisedSentence];
			[alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
			[alert show];
		}];
    }
}

@end
