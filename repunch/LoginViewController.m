//
//  LoginViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LoginViewController.h"

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
	
	CAGradientLayer *bgLayer2 = [GradientBackground blackButtonGradient];
	bgLayer2.frame = self.loginButton.bounds;
	[self.loginButton.layer insertSublayer:bgLayer2 atIndex:0];
	[self.loginButton.layer setCornerRadius:5];
	[self.loginButton setClipsToBounds:YES];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.loginButton.bounds;
	spinner.hidesWhenStopped = YES;
	[self.loginButton addSubview:spinner];
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

- (IBAction)loginWithRepunch:(id)sender
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
	
	[self.loginButton setTitle:@"" forState:UIControlStateNormal];
	[self.loginButton setEnabled:NO];
	[self.facebookButton setEnabled:NO];
	[spinner startAnimating];
        
	[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error)
	{
		if (user)
		{
			NSString *accountType = [user objectForKey:@"account_type"];
			
			if( [accountType isEqualToString:@"patron"] ) {
				NSString *patronId = [[user objectForKey:@"Patron"] objectId];
				[self fetchPatronPFObject:patronId];
				
			} else {
				NSLog(@"Account exists but is not of type 'patron'");
				[self handleError:nil withTitle:@"Login Failed" andMessage:@"Please check your username/password"];
			}
		}
		else
		{
			[self handleError:nil withTitle:@"Login Failed" andMessage:@"Please check your username/password"];
		}
	}]; //end get user block
}

- (void)fetchPatronPFObject:(NSString*)patronId
{	
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
		[spinner stopAnimating];
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

- (IBAction)forgotPassword:(id)sender
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

- (IBAction)loginWithFacebook:(id)sender
{
	[self.loginButton setEnabled:NO];
	[self.facebookButton setEnabled:NO];
	[self.facebookSpinner startAnimating];
	[self.facebookButtonLabel setHidden:YES];
	
    NSArray *permissions = @[@"email", @"user_birthday"];
	
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
					  //TODO
					  [self handleError:error withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
				  }
			  }];
			 
		 }
		 else
		 {
			 [self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
		 }
	 }];
}

- (void)dismissKeyboard
{
    [self.usernameInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
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
	[self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
	[self.facebookButtonLabel setHidden:NO];
	[self.loginButton setEnabled:YES];
	[self.facebookButton setEnabled:YES];
}

- (void)showDialog:(NSString*)resultTitle withResultMessage:(NSString*)resultMessage
{	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:resultTitle
                                                 andMessage:resultMessage];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

@end
