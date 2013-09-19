//
//  RegisterViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"


@implementation RegisterViewController
{
	DataManager *sharedData;
	UIActivityIndicatorView *spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [DataManager getSharedInstance];
    
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
	
	self.navigationController.navigationBarHidden = NO;
	self.navigationItem.title = @"Register";
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.registerButton]
								forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.registerButton]
								forState:UIControlStateHighlighted];
	[self.registerButton.layer setCornerRadius:5];
	[self.registerButton setClipsToBounds:YES];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.registerButton.bounds;
	[self.registerButton addSubview:spinner];
	spinner.hidesWhenStopped = YES;
	
	self.facebookSpinner.hidesWhenStopped = YES;
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Avenir-Heavy" size:17]
														   forKey:NSFontAttributeName];
	[self.genderSelector setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self dismissKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	if(textField == _emailInput) {
		[_emailInput resignFirstResponder];
		[_passwordInput becomeFirstResponder];
		
	} else if(textField == _passwordInput) {
		[_passwordInput resignFirstResponder];
		[_passwordConfirmInput becomeFirstResponder];
		
	} else if(textField == _passwordConfirmInput) {
		[_passwordConfirmInput resignFirstResponder];
		[_firstNameInput becomeFirstResponder];
		
	} else if(textField == _firstNameInput) {
		[_firstNameInput resignFirstResponder];
		[_lastNameInput becomeFirstResponder];
		
	} else if(textField == _lastNameInput) {
		[_lastNameInput resignFirstResponder];
		[_ageInput becomeFirstResponder];
		
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - registration methods

- (IBAction)registerWithFacebook:(id)sender
{
    [self.facebookButtonLabel setHidden:YES];
	[self.facebookButton setEnabled:NO];
	[self.registerButton setEnabled:NO];
	[self.facebookSpinner startAnimating];
	
    NSArray *permissions = @[@"email", @"user_birthday", @"publish_actions"];
	
	[PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
	 {
		 if (!user)
		 {
			 NSLog(@"Uh oh. The user cancelled the Facebook login.");
			 [self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
		 }
		 else if (user.isNew)
		 {
			 NSLog(@"User signed up and logged in through Facebook!");
			 //get publish permissions
			 [self performFacebookSignup:user];
		 }
		 else
		 {
			 NSLog(@"User logged in through Facebook! User Object: %@", user);
			 NSString *patronId = [[user objectForKey:@"Patron"] objectId];
			 [self fetchPatronPFObject:patronId];
		 }
	 }];
}

- (IBAction)registerWithRepunch:(id)sender
{
	[self dismissKeyboard];
	
	if( ![self validateForm] ) {
		return;
	}
	
    NSString *email = [_emailInput text];
    NSString *password = [_passwordInput text];
	NSString *firstName = [_firstNameInput text];
	NSString *lastName = [_lastNameInput text];
	NSString *age = [_ageInput text];
    
	PFUser *newUser = [PFUser user];
	[newUser setUsername:email];
    [newUser setPassword:password];
    [newUser setEmail:email];
    
    [self.registerButton setTitle:@"" forState:UIControlStateNormal];
	[self.registerButton setEnabled:NO];
	[self.facebookButton setEnabled:NO];
	[spinner startAnimating];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
        if (!error)
		{
			
			NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
			int birthYear = [components year] - [age intValue];
			NSString *birthday = [NSString stringWithFormat:@"01/01/%i", birthYear];
			
			NSString *gender = (self.genderSelector.selectedSegmentIndex == 0) ? @"female" : @"male";
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										[[PFUser currentUser] objectId],	@"user_id",
										email,								@"username",
										email,								@"email",
										gender,								@"gender",	
										birthday,							@"birthday",
										firstName,							@"first_name",
										lastName,							@"last_name",
										nil];
            
            [PFCloud callFunctionInBackground:@"register_patron"
							   withParameters:parameters
										block:^(PFObject* patron, NSError *error)
			{
                if (!error)
				{
                    [sharedData setPatron:patron];
					
					NSString *patronId = [patron objectId];
					NSString *punchCode = [patron objectForKey:@"punch_code"];
                    [self setupPFInstallation:patronId withPunchCode:punchCode];
                
				}
				else
				{
					NSString *errorString = [[error userInfo] objectForKey:@"error"];
					[self handleError:nil
							withTitle:@"Registration failed"
						   andMessage:errorString];
				}
            }];
            
        }
		else
		{
			int errorCode = [[[error userInfo] objectForKey:@"code"] intValue];
			if(errorCode == kPFErrorInvalidEmailAddress ||
			   errorCode == kPFErrorUserEmailTaken ||
			   errorCode == kPFErrorUsernameTaken)
			{
				NSString *errorString = [[error userInfo] objectForKey:@"error"];
				[self handleError:nil withTitle:@"Registration Failed" andMessage:errorString];
			} else {
				[self handleError:nil
						withTitle:@"Registration Failed"
					   andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
			}
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
		[spinner stopAnimating];
		[self.facebookSpinner stopAnimating];
		[self.registerButton setTitle:@"Sign In" forState:UIControlStateNormal];
		[self.registerButton setEnabled:YES];
		[self.facebookButtonLabel setHidden:NO];
		[self.facebookButton setEnabled:YES];
		
		if(!error) { //login complete
			[appDelegate presentTabBarController];
			
		} else {
			[self handleError:nil withTitle:@"Registration Failed" andMessage:@"Sorry, something went wrong"];
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
	[_passwordConfirmInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_ageInput resignFirstResponder];
}

- (BOOL)validateForm
{
    if(_emailInput.text.length == 0 || _passwordInput.text.length == 0 || _passwordConfirmInput.text.length == 0 ||
		_firstNameInput.text.length == 0 || _lastNameInput.text.length == 0 || _ageInput.text.length == 0) {
		[self showDialog:@"Please fill in all fields" withResultMessage:nil];
        return NO;
    }
	
	if(_genderSelector.selectedSegmentIndex == UISegmentedControlNoSegment) {
		[self showDialog:@"Please specify your gender" withResultMessage:nil];
		return NO;
	}
    
    if( ![_passwordInput.text isEqualToString:_passwordConfirmInput.text] ) {
		[self showDialog:@"Passwords don't match" withResultMessage:nil];
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

- (void)performFacebookSignup:(PFUser *)currentUser
{
	[[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
	 {
		 if (!error)
		 {
			 NSString *facebookId = user.id;
			 NSString *firstName = user.first_name;
			 NSString *lastName = user.last_name;
			 NSString *birthday = user.birthday;
			 NSString *gender = [user objectForKey:@"gender"];
			 NSString *email = [user objectForKey:@"email"];
			 
			 if(email == nil) {
				 email = (id)[NSNull null];
			 }
			 
			 //register patron
			 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										 currentUser.objectId,	@"user_id",
										 currentUser.username,	@"username",
										 email,					@"email",
										 gender,				@"gender",
										 birthday,				@"birthday",
										 firstName,				@"first_name",
										 lastName,				@"last_name",
										 facebookId,			@"facebook_id",
										 nil];
			 
			 [PFCloud callFunctionInBackground:@"register_patron"
								withParameters:parameters
										 block:^(PFObject* patron, NSError *error)
			  {
				  if (!error)
				  {
					  [sharedData setPatron:patron];
					  [self setupPFInstallation:patron.objectId withPunchCode:[patron objectForKey:@"punch_code"]];
				  }
				  else
				  {
					  NSString *errorString = [[error userInfo] objectForKey:@"error"];
					  [self handleError:error withTitle:@"Registration Failed" andMessage:errorString];
				  }
			  }];
		 }
		 else
		 {
			 [self handleError:nil withTitle:@"Registration Failed" andMessage:@"Sorry, something went wrong"];
		 }
	 }];
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
			 [self handleError:nil withTitle:@"Registration Failed" andMessage:@"Sorry, something went wrong"];
		 }
	 }];
}

- (void)handleError:(NSError *)error withTitle:(NSString *)title andMessage:(NSString *)message
{
	NSLog(@"Here is the ERROR: %@", error);
	
	if([PFUser currentUser]) {
		[PFUser logOut];
	}

	[self showDialog:title withResultMessage:message];
	[spinner stopAnimating];
	[self.facebookSpinner stopAnimating];
	[self.registerButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.registerButton setEnabled:YES];
	[self.facebookButton setEnabled:YES];
	[self.facebookButtonLabel setHidden:NO];
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

@end
