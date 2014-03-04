  //
//  FacebookAuthentication.m
//  RepunchConsumer
//
//  Created by Michael Shin on 10/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AuthenticationManager.h"

@implementation AuthenticationManager

+ (void) registerWithEmail:(NSString *)email
			  withPassword:(NSString *)password
			 withFirstName:(NSString *)firstName
			  withLastName:(NSString *)lastName
			  withBirthday:(NSString *)birthday
				withGender:(NSString *)gender
	 withCompletionHandler:(AuthenticationManagerHandler)handler
{
	PFUser *newUser = [PFUser user];
	[newUser setUsername:email];
    [newUser setPassword:password];
    [newUser setEmail:email];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										//newUser.objectId,					@"user_id",
										email,								@"email",
										firstName,							@"first_name",
										lastName,							@"last_name",
										birthday,							@"birthday",
										gender,								@"gender",
										nil];
            
            [AuthenticationManager registerPatron:parameters withCompletionHandler:handler];
		}
		else {
			handler( [AuthenticationManager parseErrorCode:error] );
        }
    }];
}

+ (void)loginWithEmail:(NSString *)email
		withPassword:(NSString *)password
withCompletionHandler:(AuthenticationManagerHandler)handler;
{
	[RPUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
		 if (user)
		 {
			 RPPatron *patron = user[@"Patron" ];
			 
			 if( IS_NIL(patron) ) {
				 NSLog(@"This PFUser has no Patron object");
				 handler(kPFErrorObjectNotFound);
			 }
			 else {
				 [AuthenticationManager fetchPatronObject:patron.objectId withCompletionHandler:handler];
			 }
		 }
		 else {
			 handler( [AuthenticationManager parseErrorCode:error] );
		 }
	 }];
}

+ (void)loginWithFacebook:(AuthenticationManagerHandler)handler
{
	NSArray *permissions = @[@"email", @"user_birthday", @"publish_actions"];
	
	[PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
		 if (!user) {
			 NSLog(@"Facebook login: cancelled");
			 handler(0);
		 }
		 else if (user.isNew) {
			 NSLog(@"Facebook login: registered new user");
			 [AuthenticationManager registerWithFacebook:(RPUser *)user withCompletionHandler:handler];
		 }
		 else {
			 NSLog(@"Facebook login: signed in user");
			 RPUser *repunchUser = (RPUser *)user;
			 [AuthenticationManager fetchPatronObject:repunchUser.Patron.objectId withCompletionHandler:handler];
		 }
	 }];
}

+ (void)registerWithFacebook:(RPUser *)currentUser withCompletionHandler:(AuthenticationManagerHandler)handler
{
	[[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *graphUser, NSError *error) {
		 if (!error) {
			 
			 NSString *facebookId = graphUser.id;
			 NSString *firstName = graphUser.first_name;
			 NSString *lastName = graphUser.last_name;
			 NSString *birthday = graphUser.birthday;
			 NSString *gender = graphUser[@"gender"];
			 NSString *email = graphUser[@"email"];
			 
			 if(email == nil) {
				 email = (id)[NSNull null]; //possible for email to be null when email becomes invalid
			 }
			 
			 if(gender == nil) {
				 gender = (id)[NSNull null]; //facebook docs says gender is part of public profile but sometimes fails
			 }
			 
			 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										 //currentUser.objectId,	@"user_id",
										 email,					@"email",
										 gender,				@"gender",
										 birthday,				@"birthday",
										 firstName,				@"first_name",
										 lastName,				@"last_name",
										 facebookId,			@"facebook_id", nil];
			 
			 [AuthenticationManager registerPatron:parameters withCompletionHandler:handler];
		 }
		 else {
			 handler(0);
		 }
	 }];
}

+ (void)registerPatron:(NSDictionary *)parameters withCompletionHandler:(AuthenticationManagerHandler)handler
{
	[PFCloud callFunctionInBackground:@"register_patron"
					   withParameters:parameters
								block:^(RPPatron* patron, NSError *error) {
		 if (!error) {
			 DataManager *sharedData = [DataManager getSharedInstance];
			 [sharedData setPatron:patron];
			 
			 [AuthenticationManager setupInstallation:patron.objectId withPunchCode:patron.punch_code withCompletionHandler:handler];
		 }
		 else {
			 handler(0);
		 }
	 }];
}

+ (void)fetchPatronObject:(NSString*)patronId withCompletionHandler:(AuthenticationManagerHandler)handler
{
	if( IS_NIL(patronId) ) {
		handler(0);
	}
	
	PFQuery *query = [RPPatron query];
	query.cachePolicy = kPFCachePolicyNetworkOnly;
	
	[query getObjectInBackgroundWithId:patronId block:^(PFObject *result, NSError *error) {
		 if(!error) {
			 RPPatron *patron = (RPPatron *)result;
			 DataManager *sharedData = [DataManager getSharedInstance];
			 [sharedData setPatron:patron];
			 
			 //setup Installation
			 [AuthenticationManager setupInstallation:patron.objectId withPunchCode:patron.punch_code withCompletionHandler:handler];
		 }
		 else {
			 handler(0);
		 }
	 }];
}

+ (void)setupInstallation:(NSString*)patronId
			  withPunchCode:(NSString*)punchCode
	  withCompletionHandler:(AuthenticationManagerHandler)handler
{
	RPInstallation *installation = [RPInstallation currentInstallation];
	installation.patron_id = patronId;
	installation.punch_code = punchCode;
	[installation saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
		handler(0);
	}];
}

+ (NSInteger)parseErrorCode:(NSError *)error
{
	NSDictionary *errorInfo = [error userInfo];
	NSInteger errorCode = [errorInfo[@"code"] integerValue];
	
	return errorCode;
}

@end
