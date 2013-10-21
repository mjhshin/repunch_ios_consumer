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

- (void)repunchLogin:(NSString *)email withPassword:(NSString *)password
{
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error)
	 {
		 if (user)
		 {
			 PFObject *patronObject = [user objectForKey:@"Patron"];
			 
			 if(patronObject == (id)[NSNull null] || patronObject == nil) {
				 NSError *localError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
																  code:kPFErrorObjectNotFound
															  userInfo:nil];
				 
				 NSLog(@"This PFUser has no Patron object");
				 [self.delegate onAuthenticationResult:self
											withResult:NO
											 withError:localError];
			 }
			 else {
				 NSString *patronId = [[user objectForKey:@"Patron"] objectId];
				 [self fetchPatronObject:patronId];
			 }
		 }
		 else
		 {
			 [self.delegate onAuthenticationResult:self
											withResult:NO
											 withError:error];
		 }
	 }];
}

- (void)facebookLogin
{
	NSArray *permissions = @[@"email", @"user_birthday", @"publish_actions"];
	
	[PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
	 {
		 if (!user)
		 {
			 NSLog(@"Uh oh. The user cancelled the Facebook login.");
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
			 
			 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										 currentUser.objectId,	@"user_id",
										 email,					@"email",
										 gender,				@"gender",
										 birthday,				@"birthday",
										 firstName,				@"first_name",
										 lastName,				@"last_name",
										 facebookId,			@"facebook_id", nil];
			 
			 [self registerPatron:parameters];
		 }
		 else
		 {
			 [self.delegate onAuthenticationResult:self
										withResult:NO
										 withError:error];
		 }
	 }];
}

- (void)registerPatron:(NSDictionary *)parameters
{
	[PFCloud callFunctionInBackground:@"register_patron"
					   withParameters:parameters
								block:^(PFObject* patron, NSError *error)
	 {
		 if (!error)
		 {
			 [sharedData setPatron:patron];
			 NSString *punchCode = [patron objectForKey:@"punch_code"];
			 [self setupPFInstallation:patron.objectId withPunchCode:punchCode];
		 }
		 else
		 {
			 [self.delegate onAuthenticationResult:self
										withResult:NO
										 withError:error];
		 }
	 }];
}

- (void)fetchPatronObject:(NSString*)patronId
{
	if(patronId == (id)[NSNull null] || patronId == nil) {
		[self.delegate onAuthenticationResult:self
								   withResult:NO
									withError:nil];
	}
	
	PFQuery *query = [PFQuery queryWithClassName:@"Patron"];
	//query.cachePolicy = kPFCachePolicyIgnoreCache;
	query.cachePolicy = kPFCachePolicyNetworkOnly;
	
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
