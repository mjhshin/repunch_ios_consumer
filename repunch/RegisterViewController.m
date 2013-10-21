//
//  RegisterViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"


@implementation RegisterViewController
{
	AuthenticationManager *authenticationManager;
	UIActivityIndicatorView *registerButtonSpinner;
	UIActivityIndicatorView *webViewSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	authenticationManager = [AuthenticationManager getSharedInstance];
    
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
	
	UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlack;
    numberToolbar.items = [NSArray arrayWithObjects:
						   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)],
						   nil];
    [numberToolbar sizeToFit];
    self.ageInput.inputAccessoryView = numberToolbar;
	
	self.navigationItem.title = @"Register";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.registerButton]
								forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.registerButton]
								forState:UIControlStateHighlighted];
	[self.registerButton.layer setCornerRadius:5];
	[self.registerButton setClipsToBounds:YES];
	
	registerButtonSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	registerButtonSpinner.frame = self.registerButton.bounds;
	[self.registerButton addSubview:registerButtonSpinner];
	registerButtonSpinner.hidesWhenStopped = YES;
	
	self.facebookSpinner.hidesWhenStopped = YES;
	
	webViewSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	webViewSpinner.hidesWhenStopped = YES;
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Avenir-Heavy" size:17]
														   forKey:NSFontAttributeName];
	[self.genderSelector setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	authenticationManager.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    //[self dismissKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [self disableViews:YES];
	
    [authenticationManager facebookLogin];
}

- (IBAction)registerWithRepunch:(id)sender
{
	[self dismissKeyboard];
	
	if( ![self validateForm] ) {
		return;
	}
	
	//make lowercase and strip trailing/leading whitespace
    NSString *lowercaseEmail = [_emailInput.text lowercaseString];
	NSRange range = [lowercaseEmail rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
	NSString *email = [lowercaseEmail stringByReplacingCharactersInRange:range withString:@""];
	
    NSString *password = _passwordInput.text;
	NSString *firstName = _firstNameInput.text;
	NSString *lastName = _lastNameInput.text;
	NSString *age = _ageInput.text;
	
	[self disableViews:NO];
    
	PFUser *newUser = [PFUser user];
	[newUser setUsername:email];
    [newUser setPassword:password];
    [newUser setEmail:email];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
        if (!error)
		{
			NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
			int birthYear = [components year] - [age intValue];
			NSString *birthday = [NSString stringWithFormat:@"01/01/%i", birthYear];
			
			NSString *gender = (self.genderSelector.selectedSegmentIndex == 0) ? @"female" : @"male";
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										newUser.objectId,					@"user_id",
										email,								@"email",
										gender,								@"gender",	
										birthday,							@"birthday",
										firstName,							@"first_name",
										lastName,							@"last_name", nil];
            
            [authenticationManager registerPatron:parameters];
        }
		else
		{
			[self enableViews];
			[self parseError:error];
        }
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int movementDistance = textField.frame.origin.y;	
    [self.scrollView setContentOffset:CGPointMake(0, movementDistance - 25) animated:YES];
}

- (void)dismissKeyboard
{
	[self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
	
    [_emailInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_ageInput resignFirstResponder];
}

- (void)enableViews
{
	[registerButtonSpinner stopAnimating];
	[self.registerButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.registerButton setEnabled:YES];
	
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
		[self.registerButton setTitle:@"" forState:UIControlStateNormal];
		[self.registerButton setEnabled:NO];
		[self.facebookButton setEnabled:NO];
		[registerButtonSpinner startAnimating];
	}
}

- (BOOL)validateForm
{
    if(_emailInput.text.length == 0 || _passwordInput.text.length == 0 ||
		_firstNameInput.text.length == 0 || _lastNameInput.text.length == 0 || _ageInput.text.length == 0) {
		[self showDialog:@"Please fill in all fields" withResultMessage:nil];
        return NO;
    }
	
	if(_genderSelector.selectedSegmentIndex == UISegmentedControlNoSegment) {
		[self showDialog:@"Please specify your gender" withResultMessage:nil];
		return NO;
	}
    
    if( _passwordInput.text.length < 6 ) {
		[self showDialog:@"Registration Failed" withResultMessage:@"Passwords must be at least 6 characters"];
		return NO;
	}
	
	if( [_ageInput.text intValue] < 13 ) {
		[self showDialog:@"Registration Failed" withResultMessage:@"Sorry, but you must be at least 13 years old to sign up"];
		return NO;
	}
	
	if( [_ageInput.text intValue] > 125 ) {
		[self showDialog:@"Please enter your real age" withResultMessage:nil];
		return NO;
	}
    
    return YES;
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
	
	if(errorCode == kPFErrorInvalidEmailAddress ||
	   errorCode == kPFErrorUserEmailTaken ||
	   errorCode == kPFErrorUsernameTaken)
	{
		message = [errorInfo objectForKey:@"error"];
	}
	else
	{
		message = @"There was a problem connecting to Repunch. Please check your connection and try again.";
	}
	
	[self showDialog:@"Registration Failed" withResultMessage:message];
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
}

@end
