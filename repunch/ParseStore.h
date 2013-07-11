//
//  ParseStore.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

//PARSE STORE OBJECT TO INTERACT WITH PARSE BACKEND
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseStore : NSObject

//signing in and registering
-(void)signUserWithFacebook;
-(void)signUserInWithUsername:(NSString *)username
                  andPassword: (NSString *)password;

-(void)registerUserWithFacebook;
-(void)registerUserInWithUsername:(NSString *)username
                      andPassword: (NSString *)password
                         andEmail: (NSString *)email
            andUserInfoDictionary: (NSDictionary *)userInfo;


//fetching data
-(PFObject *)getPatronObjectForCurrentUser;


@end

