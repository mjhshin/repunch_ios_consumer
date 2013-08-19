//
//  FacebookAuthentication.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/16/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "FacebookAuthentication.h"

@implementation FacebookAuthentication

- (void)authenticate
{
	NSArray *permissions = @[@"email", @"user_birthday"];
	
	[PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
	{
		if (!user)
		{
			NSLog(@"Uh oh. The user cancelled the Facebook login.");
			[self.delegate onAuthenticated:self forPatron:nil withError:error];
		}
		else if (user.isNew)
		{
			NSLog(@"User signed up and logged in through Facebook!");
			//get publish permissions
			[self performSignup:user];
		}
		else
		{
			NSLog(@"User logged in through Facebook!");
		}
	}];
}

- (void)performSignup:(PFUser *)currentUser
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
										gender,					@"gender",
										birthday,				@"birthday",
										firstName,				@"first_name",
										lastName,				@"last_name",
										facebookId,				@"facebook_id",
										nil];
			
			[PFCloud callFunctionInBackground:@"register_patron"
							   withParameters:parameters
										block:^(PFObject* patron, NSError *error)
			 {
				 if (!error)
				 {
					 
				 }
				 else
				 {
					 
				 }
			 }];
			
		}
		else
		{
			
		}
	}];
}

@end
