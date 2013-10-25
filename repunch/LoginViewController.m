
//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "AuthenticationManager.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Sign In";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
	
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.loginButton]
								forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.loginButton]
								forState:UIControlStateHighlighted];
	[self.loginButton.layer setCornerRadius:5];
	[self.loginButton setClipsToBounds:YES];
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
		[RepunchUtils showDialogWithTitle:@"Please enter your email" withMessage:nil];
		return;
		
	} else if(password.length == 0) {
		[RepunchUtils showDialogWithTitle:@"Please enter your password" withMessage:nil];
		return;
	}
	
	[self disableViews:NO];
	
	[AuthenticationManager loginWithEmail:email withPassword:password withCompletionHandler:^(NSInteger errorCode) {
		[self handleAuthenticationResult:errorCode];
	}];
}

- (IBAction)loginWithFacebook:(id)sender
{
	[self disableViews:YES];
	
	[AuthenticationManager loginWithFacebook:^(NSInteger errorCode) {
		[self handleAuthenticationResult:errorCode];
	}];
}

- (void)handleAuthenticationResult:(NSInteger)errorCode
{
	[self enableViews];
	
	if(errorCode == 0) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate presentTabBarController];
	}
	else {
		if(errorCode == kPFErrorObjectNotFound) {
			[RepunchUtils showDialogWithTitle:@"Login Failed"
								  withMessage:@"Invalid email/password"];
		}
		else {
			[RepunchUtils showDialogWithTitle:@"Login Failed"
								  withMessage:@"Sorry, something went wrong. Please try again."];
		}
		
		if([PFUser currentUser]) {
			[PFUser logOut];
		}
	}
}

- (void)dismissKeyboard
{
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}

- (void)enableViews
{
	[self.loginButtonSpinner stopAnimating];
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
		[self.loginButtonSpinner startAnimating];
	}
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
		
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
			NSString *titleString;
			NSString *messageString;
			
			if(!error) {
				titleString = @"Success!";
				messageString = @"Instructions to reset your password have been sent to your email";
			}
			else {
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
			
			[RepunchUtils showDialogWithTitle:titleString withMessage:capitalisedSentence];
		}];
    }
}

@end
