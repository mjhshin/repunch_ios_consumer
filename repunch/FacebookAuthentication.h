//
//  FacebookAuthentication.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/16/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@class FacebookAuthentication;

@protocol FacebookAuthenticationDelegate <NSObject>
- (void)onAuthenticated:(FacebookAuthentication *)object forPatron:(PFObject *)patron withError:(NSError *)error;
@end

@interface FacebookAuthentication : NSObject

- (void) authenticate;
- (void) performSignup;

@property (nonatomic, weak) id <FacebookAuthenticationDelegate> delegate;

@end
