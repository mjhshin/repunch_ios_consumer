//
//  RegisterViewController.m
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"


//TODO: TEST THIS WORKS.
//TODO: ALLLL THE FACEBOOK STUFF.

@implementation RegisterViewController

#pragma mark - setup methods
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //tap gesture to dismiss keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    CGRect contentRect = CGRectZero;
    for ( UIView *subview in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, subview.frame);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(contentRect)+10);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI response methods

- (IBAction)registerBtn:(id)sender {
    if (![self validateForm]) {
        return;
    }

    NSString *username = [_usernameInput text];
    NSString *password = [_passwordInput text];
    NSString *fName = [_firstNameInput text];
    NSString *lName = [_lastNameInput text];
    NSString *email = [_emailInput text];
    NSString *birthday = [_birthdayInput text];
    NSString *gender = [_genderInput text];
    
    [self dismissKeyboard];
    
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = email;
    [newUser setValue:@"patron" forKey:@"account_type"];
    
    //spinner to run while fetches happen
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 480);
    spinner.color = [UIColor blackColor];
    [[self view] addSubview:spinner];
    [spinner startAnimating];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            [spinner stopAnimating];
            PFObject *newPatron = [PFObject objectWithClassName:@"Patron"];
            [newPatron setValue:@"first_name" forKey:fName];
            [newPatron setValue:@"last_name" forKey:lName];
            [newPatron setValue:@"gender" forKey:gender];
            [newPatron setValue:@"date_of_birth" forKey:birthday];
            //TODO: CLOUD CODE TO GENERATE PUNCH CODES
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_createInContext:localContext];
            [localUser setFromParseUserObject:newUser andPatronObject:newPatron];
            [localContext MR_saveToPersistentStoreAndWait];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.window setRootViewController:appDelegate.tabBarController];

        }
        
        else{
            [spinner stopAnimating];
            //TODO: HERE BE ERROR CODES
            NSLog(@"There was an ERROR: %@", error);
        }
    }];
    

}

- (IBAction)cancelBtn:(id)sender {
    [[self modalDelegate] didDismissPresentedViewController];
}

#pragma mark - UI gesture methods

-(void)dismissKeyboard {
    [_usernameInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
    [_firstNameInput resignFirstResponder];
    [_lastNameInput resignFirstResponder];
    [_emailInput resignFirstResponder];
    [_genderInput resignFirstResponder];
    [_birthdayInput resignFirstResponder];
    
}

#pragma mark - Data validation methods

- (BOOL)validateForm
{
    NSMutableString *errMsg = [NSMutableString stringWithString:@""];
    
    if (_usernameInput.text.length <= 0) {
        [errMsg appendString:@"Username is required.\n"];
    }
    
    if (_passwordInput.text.length <= 0) {
        [errMsg appendString:@"Password is required.\n"];
    }
    
    if (_emailInput.text.length <= 0) {
        [errMsg appendString:@"Email is required.\n"];
        
    } else if (![self validateEmail:_emailInput.text]) {
        [errMsg appendString:@"Invalid email address.\n"];
    }
    
    if (_birthdayInput.text.length <=0){
        [errMsg appendString:@"Birthday is required.\n"];
    }
    if (_genderInput.text.length <=0)
    {
        [errMsg appendString:@"Gender is required.\n"];
    }
    if (errMsg.length > 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Registration Error" message:errMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] ;
        [av show];
        return NO;
    }
    
    return YES;
}
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}



@end
