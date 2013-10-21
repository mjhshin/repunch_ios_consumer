//
//  FacebookAuthentication.h
//  RepunchConsumer
//
//  Created by Michael Shin on 10/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@class AuthenticationManager;

@protocol  AuthenticationManagerDelegate <NSObject>
- (void)onAuthenticationResult:(AuthenticationManager *)object
					withResult:(BOOL)success
					 withError:(NSError *)error;
@end

@interface AuthenticationManager : NSObject

+ (AuthenticationManager *) getSharedInstance;

@property (nonatomic, weak) id <AuthenticationManagerDelegate> delegate;

- (void) repunchLogin:(NSString *)email withPassword:(NSString *)password;
- (void) facebookSignup:(PFUser *)currentUser;
- (void) facebookLogin;
- (void) fetchPatronObject:(NSString*)patronId;
- (void) registerPatron:(NSDictionary *)parameters;
- (void) setupPFInstallation:(NSString*)patronId withPunchCode:(NSString*)punchCode;

@end
