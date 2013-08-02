//
//  RegisterViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"
#import "SharedData.h"
#import "AppDelegate.h"
#import "GradientBackground.h"

@implementation RegisterViewController
{
	SharedData *sharedData;
    UIActivityIndicatorView *spinner;
    UIDatePicker *datePicker;
    NSArray *pickerItems;
    UIPickerView *genderPicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [SharedData init];
    
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 100);
    spinner.color = [UIColor grayColor];
    [[self view] addSubview:spinner];
    
    pickerItems = @[@"female", @"male"];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.view.bounds;
	[self.view.layer insertSublayer:bgLayer atIndex:0];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToPlaces)
                                                 name:@"finishedLoggingIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showError)
                                                 name:@"errorLoggingIn"
                                               object:nil];*/  
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedLoggingIn" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"errorLoggingIn" object:nil];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	if(textField == _usernameInput) {
		[_usernameInput resignFirstResponder];
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
		[_emailInput becomeFirstResponder];
		
	} else if(textField == _emailInput) {
		[_emailInput resignFirstResponder];
		[_ageInput becomeFirstResponder];
		
	} else if(textField == _ageInput) {
		[_ageInput resignFirstResponder];
		
	}
	
	return NO; // We do not want UITextField to insert line-breaks.
}

-(void)showError {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"There was an error."
                          message:@"Sorry, something went wrong."
                          delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles: nil];
    [alert show];
}

#pragma mark - registration methods

- (IBAction)registerWithFB:(id)sender
{
    [spinner startAnimating];
}

- (IBAction)registerWithEmail:(id)sender
{
	[self dismissKeyboard];
	
	if( ![self validateForm] ) {
		return;
	}
	
    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
	NSString *firstName = [_firstNameInput text];
	NSString *lastName = [_lastNameInput text];
	NSString *age = [_ageInput text];
    NSString *email = [_emailInput text];
    
	PFUser *newUser = [PFUser user];
	[newUser setUsername:username];
    [newUser setPassword:password];
    [newUser setEmail:email];
    [newUser setValue:@"patron" forKey:@"account_type"];
    
    //spinner to run while fetches happen
    //spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.center = CGPointMake(160, 480);
    //spinner.color = [UIColor blackColor];
    //[[self view] addSubview:spinner];
    //[spinner startAnimating];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		//[spinner stopAnimating];
        if (!error){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										[[PFUser currentUser] objectId], @"user_id",
										username, @"username",
										email, @"email",
										@"male", @"gender",	//TODO
										@"05/15/88", @"birthday",	//TODO
										firstName, @"first_name",
										lastName, @"last_name",
										nil];
            
            [PFCloud callFunctionInBackground:@"register_patron"
							   withParameters:parameters
										block:^(PFObject* patron, NSError *error) {
                if (!error){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [sharedData setPatron:patron];
					
					NSString *patronId = [patron objectId];
					NSString *punchCode = [patron objectForKey:@"punch_code"];
                    [self setupPFInstallation:patronId withPunchCode:punchCode];
                
				} else {
					NSDictionary *parseError = [error userInfo];
					NSInteger errorCode = [[parseError valueForKey:@"error"] intValue];
					
					if( errorCode == kPFErrorUserEmailTaken ) {
						NSString *msgPart1 = @"Sorry, the email ";
						NSString *msgPart2 = @" is already taken";
					
						[self showDialog:@"Registration failed"
					   withResultMessage:[NSString stringWithFormat:@"%@%@%@", msgPart1, email, msgPart2]];
						
					} else { //TODO: error codes!!!
						[self showDialog:@"Registration Failed" withResultMessage:@"Sorry, something went wrong"];
                    
					}
				}
            }];
            
        } else {
            [self showDialog:@"Registration Failed" withResultMessage:@"Sorry, something went wrong"];
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
		
		if(!error) { //login complete
			[appDelegate presentTabBarController];
			
		} else {
			[self showDialog:@"Registration Failed" withResultMessage:@"Sorry, something went wrong"];
			[PFUser logOut];
		}
	}];
}

- (IBAction)cancelRegistration:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
	[_passwordConfirmInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_emailInput resignFirstResponder];
    [_ageInput resignFirstResponder];
}

- (BOOL)validateForm
{
    if (_usernameInput.text.length == 0 || _passwordInput.text.length == 0 || _passwordConfirmInput.text.length == 0 || 
		_firstNameInput.text.length == 0 || _lastNameInput.text.length == 0 || _emailInput.text.length == 0 ||
		_ageInput.text.length == 0) {
		[self showDialog:@"Please fill in all fields" withResultMessage:nil];
        return NO;
    }
	
	if(_genderSelector.selectedSegmentIndex == UISegmentedControlNoSegment) {
		[self showDialog:@"Please specify your gender" withResultMessage:nil];
		return NO;
	}
    
    if ( ![_passwordInput.text isEqualToString:_passwordConfirmInput.text] ) {
		[self showDialog:@"Passwords don't match" withResultMessage:nil];
		return NO;
	}
    
    return YES;
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
