//
//  RegisterViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "AuthenticationManager.h"

@implementation RegisterViewController
{
	UIActivityIndicatorView *webViewSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Register";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
	
	UIToolbar* numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlack;
    numberToolbar.items = [NSArray arrayWithObjects:
						   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		 target:nil
																		 action:nil],
						   [[UIBarButtonItem alloc] initWithTitle:@"Done"
															style:UIBarButtonItemStyleDone
														   target:self
														   action:@selector(dismissKeyboard)],
						   nil];
    [numberToolbar sizeToFit];
	
    self.ageInput.inputAccessoryView = numberToolbar;
	
	webViewSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	webViewSpinner.hidesWhenStopped = YES;
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[RepunchUtils repunchFontWithSize:17 isBold:YES]
														   forKey:NSFontAttributeName];
	[self.genderSelector setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	if(textField == _emailInput) {
		[_emailInput resignFirstResponder];
		[_passwordInput becomeFirstResponder];
	}
	else if(textField == _passwordInput) {
		[_passwordInput resignFirstResponder];
		[_firstNameInput becomeFirstResponder];
	}
	else if(textField == _firstNameInput) {
		[_firstNameInput resignFirstResponder];
		[_lastNameInput becomeFirstResponder];
	}
	else if(textField == _lastNameInput) {
		[_lastNameInput resignFirstResponder];
		[_ageInput becomeFirstResponder];
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)registerWithFacebook:(id)sender
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
    [self disableViews:YES];
	
    [AuthenticationManager loginWithFacebook:^(NSInteger errorCode) {
		[self handleAuthenticationResult:errorCode];
	}];
}

- (IBAction)registerWithRepunch:(id)sender
{
	[self dismissKeyboard];
	
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	else if( ![self validateForm] ) {
		return;
	}
	
	//make lowercase
    NSString *lowercaseEmail = [_emailInput.text lowercaseString];

	//strip trailing/leading whitespace
	NSRange range = [lowercaseEmail rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
	NSString *email = [lowercaseEmail stringByReplacingCharactersInRange:range withString:@""];
	
    NSString *password = _passwordInput.text;
	NSString *firstName = _firstNameInput.text;
	NSString *lastName = _lastNameInput.text;
	NSString *age = _ageInput.text;
	NSString *gender = (self.genderSelector.selectedSegmentIndex == 0) ? @"female" : @"male";
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
	int birthYear = [components year] - [age intValue];
	NSString *birthday = [NSString stringWithFormat:@"01/01/%i", birthYear];
	
	[self disableViews:NO];
	
	[AuthenticationManager registerWithEmail:email
								withPassword:password
							   withFirstName:firstName
								withLastName:lastName
								withBirthday:birthday
								  withGender:gender
					   withCompletionHandler:^(NSInteger errorCode) {
						   [self handleAuthenticationResult:errorCode];
					   }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int movementDistance = textField.frame.origin.y;	
    [self.scrollView setContentOffset:CGPointMake(0, movementDistance - 72) animated:YES];
}

- (void)dismissKeyboard
{
	[self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
							 animated:YES];
	
    [_emailInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_ageInput resignFirstResponder];
}

- (void)enableViews
{
	[self.registerButton stopSpinner];
	
	[self.facebookSpinner stopAnimating];
	[self.facebookButtonLabel setHidden:NO];
	[self.facebookButton setEnabled:YES];
}

- (void)disableViews:(BOOL)isFacebook
{
	if(isFacebook) {
		[self.facebookButtonLabel setHidden:YES];
		[self.facebookButton setEnabled:NO];
		[self.registerButton setEnabled:NO];
		[self.facebookSpinner startAnimating];
	}
	else {
		[self.facebookButton setEnabled:NO];
		
		[self.registerButton startSpinner];
	}
}

- (BOOL)validateForm
{
    if(_emailInput.text.length == 0 || _passwordInput.text.length == 0 ||
		_firstNameInput.text.length == 0 || _lastNameInput.text.length == 0 || _ageInput.text.length == 0) {
		[RepunchUtils showDialogWithTitle:@"Please fill in all fields"
							  withMessage:nil];
        return NO;
    }
	
	if(_genderSelector.selectedSegmentIndex == UISegmentedControlNoSegment) {
		[RepunchUtils showDialogWithTitle:@"Please specify your gender"
							  withMessage:nil];
		return NO;
	}
    
    if( _passwordInput.text.length < 6 ) {
		[RepunchUtils showDialogWithTitle:@"Passwords must be at least 6 characters"
							  withMessage:nil];
		return NO;
	}
	
	if( [_ageInput.text intValue] < 13 ) {
		[RepunchUtils showDialogWithTitle:@"Sorry, but you must be at least 13 years old to sign up"
							  withMessage:nil];
		return NO;
	}
	
	if( [_ageInput.text intValue] > 125 ) {
		[RepunchUtils showDialogWithTitle:@"Please enter your real age"
							  withMessage:nil];
		return NO;
	}
    
    return YES;
}

- (void)handleAuthenticationResult:(NSInteger)errorCode
{
	[self enableViews];
	
	if(errorCode == 0) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate presentTabBarController];
	}
	else {
		if(errorCode == kPFErrorInvalidEmailAddress) {
			[RepunchUtils showDialogWithTitle:@"Registration Failed"
								  withMessage:@"Please enter a valid email"];
		}
		else if(errorCode == kPFErrorUserEmailTaken ||
				errorCode == kPFErrorUsernameTaken) {
			[RepunchUtils showDialogWithTitle:@"Registration Failed"
								  withMessage:@"Another user is already using this email"];
		}
		else {
			[RepunchUtils showDialogWithTitle:@"Registration Failed"
								  withMessage:@"Sorry, something went wrong. Please try again."];
		}
		
		if([RPUser currentUser]) {
			[RPUser logOut];
		}
	}
}

- (IBAction)termsAndConditions:(id)sender
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.repunch.com/terms-mobile"]]];
	webView.delegate = self;
	
	UIViewController *termsVC = [[UIViewController alloc] init];
	[termsVC.view addSubview:webView];
	[termsVC.view addSubview:webViewSpinner];
	webViewSpinner.center = webView.center;
	
	termsVC.navigationItem.title = @"Terms and Conditions";
	[self.navigationController pushViewController:termsVC animated:YES];
}

- (IBAction)privacyPolicy:(id)sender
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.repunch.com/privacy-mobile"]]];
	webView.delegate = self;
	
	UIViewController *privacyVC = [[UIViewController alloc] init];
	[privacyVC.view addSubview:webView];
	[privacyVC.view addSubview:webViewSpinner];
	webViewSpinner.center = webView.center;
	
	privacyVC.navigationItem.title = @"Privacy Policy";
	[self.navigationController pushViewController:privacyVC animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [webViewSpinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webViewSpinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webViewSpinner stopAnimating];
	[RepunchUtils showDefaultDropdownView:webView];
}

@end
