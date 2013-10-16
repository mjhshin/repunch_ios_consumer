//
//  FacebookAuthentication.m
//  RepunchConsumer
//
//  Created by Michael Shin on 10/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AuthenticationManager.h"
#import <Foundation/Foundation.h>
#import "DataManager.h"

@implementation AuthenticationManager
{
	DataManager *sharedData;
}

static AuthenticationManager *sharedAuthenticationManager = nil;    // static instance variable

+ (AuthenticationManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuthenticationManager = [[AuthenticationManager alloc] init];
    });
    return sharedAuthenticationManager;
}

- (id) init
{
	if (self = [super init]) {
        sharedData = [DataManager getSharedInstance];
	}
	return self;
}

- (void) facebookLogin
{
	NSArray *permissions = @[@"email", @"user_birthday", @"publish_actions"];
	
	[PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
	 {
		 if (!user)
		 {
			 NSLog(@"Uh oh. The user cancelled the Facebook login.");
			 //[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
			 [self.delegate onAuthenticationResult:self
										withResult:NO
										 withError:error];
		 }
		 else if (user.isNew)
		 {
			 NSLog(@"User signed up and logged in through Facebook!");
			 [self facebookSignup:user];
		 }
		 else
		 {
			 NSLog(@"User logged in through Facebook! User Object: %@", user);
			 NSString *patronId = [[user objectForKey:@"Patron"] objectId];
			 [self fetchPatronObject:patronId];
		 }
	 }];
}

- (void)facebookSignup:(PFUser *)currentUser
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
				 email = (id)[NSNull null]; //Possible if facebook user has invalid email - deny registration?
			 }
			 
			 //register patron
			 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										 currentUser.objectId,	@"user_id",
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
					  //NSString *errorString = [[error userInfo] objectForKey:@"error"];
					  //[self handleError:error withTitle:@"Login Failed" andMessage:errorString];
					  [self.delegate onAuthenticationResult:self
												 withResult:NO
												  withError:error];
				  }
			  }];
			 
		 }
		 else
		 {
			 //[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
			 [self.delegate onAuthenticationResult:self
										withResult:NO
										 withError:error];
		 }
	 }];
}

- (void)fetchPatronObject:(NSString*)patronId
{
	if(patronId == (id)[NSNull null] || patronId == nil) {
		//[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
		[self.delegate onAuthenticationResult:self
								   withResult:NO
									withError:nil];
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
			 //[self handleError:nil withTitle:@"Login Failed" andMessage:@"Sorry, something went wrong"];
			 [self.delegate onAuthenticationResult:self
										withResult:NO
										 withError:error];
		 }
	 }];
}

- (void)setupPFInstallation:(NSString*)patronId withPunchCode:(NSString*)punchCode
{
	[[PFInstallation currentInstallation] setObject:patronId forKey:@"patron_id"];
	[[PFInstallation currentInstallation] setObject:punchCode forKey:@"punch_code"];
	[[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL success, NSError *error)
	 {
		 [self.delegate onAuthenticationResult:self
									withResult:success
									 withError:error];
	 }];
}

@end
