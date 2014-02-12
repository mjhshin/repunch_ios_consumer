//
//  FacebookAuthentication.h
//  RepunchConsumer
//
//  Created by Michael Shin on 10/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "RPConstants.h"
#import "DataManager.h"

@interface AuthenticationManager : NSObject

+ (void) registerWithEmail:(NSString *)email
			  withPassword:(NSString *)password
			 withFirstName:(NSString *)firstName
			  withLastName:(NSString *)lastName
			  withBirthday:(NSString *)birthday
				withGender:(NSString *)gender
	 withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (void) loginWithEmail:(NSString *)email
		 withPassword:(NSString *)password
withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (void) registerWithFacebook:(RPUser *)currentUser
  withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (void) loginWithFacebook:(AuthenticationManagerHandler)handler;

+ (void) fetchPatronObject:(NSString*)patronId
	 withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (void) registerPatron:(NSDictionary *)parameters
  withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (void) setupInstallation:(NSString*)patronId
			   withPunchCode:(NSString*)punchCode
	   withCompletionHandler:(AuthenticationManagerHandler)handler;

+ (NSInteger) parseErrorCode:(NSError *)error;

@end
