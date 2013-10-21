
//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController
{
	AuthenticationManager *authenticationManager;
	UIActivityIndicatorView *loginButtonSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	authenticationManager = [AuthenticationManager getSharedInstance];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	authenticationManager.delegate = self;
	
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
	
	[self disableViews:NO];
	
	[authenticationManager repunchLogin:email withPassword:password];
}

- (IBAction)loginWithFacebook:(id)sender
{
	[self disableViews:YES];
	
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
	
	[self enableViews];
	
	if([PFUser currentUser]) {
		[PFUser logOut];
	}
	
	[self showDialog:title withResultMessage:message];
}

- (void)onAuthenticationResult:(AuthenticationManager *)object withResult:(BOOL)success withError:(NSError *)error
{
	[self enableViews];
	
	if(success)
	{
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate presentTabBarController];
	}
	else
	{
		NSLog(@"onAuthenticationResult ERROR: %@", error);
		
		if([PFUser currentUser]) {
			[PFUser logOut];
		}
		
		[self parseError:error];
	}
}

- (void)parseError:(NSError *)error
{
	NSDictionary *errorInfo = [error userInfo];
	NSInteger errorCode = [[errorInfo objectForKey:@"code"] integerValue];
	NSString *message;
	
	if(errorCode == kPFErrorObjectNotFound || error.code == kPFErrorObjectNotFound) {
		message = @"Invalid email/password";
	}
	else {
		message = @"There was a problem connecting to Repunch. Please check your connection and try again.";
	}
	
	[self showDialog:@"Login Failed" withResultMessage:message];
}

- (void)enableViews
{
	[loginButtonSpinner stopAnimating];
	[self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.loginButton setEnabled:YES];
	
	[self.facebookSpinner stopAnimating];
	[self.facebookButtonLabel setHidden:NO];
	[self.facebookButton setEnabled:YES];
}

- (void)disableViews:(BOOL)isFacebook
{
	if(isFacebook) {
		[self.loginButton setEnabled:NO];
		[self.facebookButton setEnabled:NO];
		[self.facebookSpinner startAnimating];
		[self.facebookButtonLabel setHidden:YES];
	}
	else {
		[self.loginButton setTitle:@"" forState:UIControlStateNormal];
		[self.loginButton setEnabled:NO];
		[self.facebookButton setEnabled:NO];
		[loginButtonSpinner startAnimating];
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
