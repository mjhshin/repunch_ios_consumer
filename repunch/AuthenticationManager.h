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

- (void) facebookSignup:(PFUser *)currentUser;
- (void) facebookLogin;
- (void) fetchPatronObject:(NSString*)patronId;
- (void) setupPFInstallation:(NSString*)patronId withPunchCode:(NSString*)punchCode;

@end
