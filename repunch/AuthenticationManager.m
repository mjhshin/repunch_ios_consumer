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
										newUser.objectId,					@"user_id",
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
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
		 if (user)
		 {
			 PFObject *patron = [user objectForKey:@"Patron"];
			 
			 if( IS_NIL(patron) ) {
				 NSLog(@"This PFUser has no Patron object");
				 handler(kPFErrorObjectNotFound);
			 }
			 else {
				 NSString *patronId = [[user objectForKey:@"Patron"] objectId];
				 [AuthenticationManager fetchPatronObject:patronId withCompletionHandler:handler];
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
			 [AuthenticationManager registerWithFacebook:user withCompletionHandler:handler];
		 }
		 else {
			 NSLog(@"Facebook login: signed in user");
			 NSString *patronId = [[user objectForKey:@"Patron"] objectId];
			 [AuthenticationManager fetchPatronObject:patronId withCompletionHandler:handler];
		 }
	 }];
}

+ (void)registerWithFacebook:(PFUser *)currentUser withCompletionHandler:(AuthenticationManagerHandler)handler
{
	[[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
		 if (!error) {
			 
			 NSString *facebookId = user.id;
			 NSString *firstName = user.first_name;
			 NSString *lastName = user.last_name;
			 NSString *birthday = user.birthday;
			 NSString *gender = [user objectForKey:@"gender"];
			 NSString *email = [user objectForKey:@"email"];
			 
			 if(email == nil) {
				 email = (id)[NSNull null]; //possible for email to be null when email becomes invalid
			 }
			 
			 if(gender == nil) {
				 gender = (id)[NSNull null]; //facebook docs says gender is part of public profile but sometimes fails
			 }
			 
			 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
										 currentUser.objectId,	@"user_id",
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
								block:^(PFObject* patron, NSError *error) {
		 if (!error) {
			 DataManager *sharedData = [DataManager getSharedInstance];
			 [sharedData setPatron:patron];
			 
			 NSString *punchCode = [patron objectForKey:@"punch_code"];
			 
			 [AuthenticationManager setupPFInstallation:patron.objectId withPunchCode:punchCode withCompletionHandler:handler];
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
	
	PFQuery *query = [PFQuery queryWithClassName:@"Patron"];
	query.cachePolicy = kPFCachePolicyNetworkOnly;
	
	[query getObjectInBackgroundWithId:patronId block:^(PFObject *patron, NSError *error) {
		 if(!error) {
			 DataManager *sharedData = [DataManager getSharedInstance];
			 [sharedData setPatron:patron];
			 
			 //setup PFInstallation
			 NSString *patronId = [patron objectId];
			 NSString *punchCode = [patron objectForKey:@"punch_code"];
			 [AuthenticationManager setupPFInstallation:patronId withPunchCode:punchCode withCompletionHandler:handler];
		 }
		 else {
			 handler(0);
		 }
	 }];
}

+ (void)setupPFInstallation:(NSString*)patronId
			  withPunchCode:(NSString*)punchCode
	  withCompletionHandler:(AuthenticationManagerHandler)handler
{
	[[PFInstallation currentInstallation] setObject:patronId forKey:@"patron_id"];
	[[PFInstallation currentInstallation] setObject:punchCode forKey:@"punch_code"];
	[[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
		handler(0);
	}];
}

+ (NSInteger)parseErrorCode:(NSError *)error
{
	NSDictionary *errorInfo = [error userInfo];
	NSInteger errorCode = [[errorInfo objectForKey:@"code"] integerValue];
	
	return errorCode;
}

@end
