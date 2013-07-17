//
//  ParseStore.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "ParseStore.h"
#import "AppDelegate.h"

#import "User.h"

@implementation ParseStore

-(PFObject *)getPatronObjectForCurrentUser {
    PFObject *patronObject = [[PFUser currentUser] valueForKey:@"Patron"];
    return [patronObject fetchIfNeeded];
}

-(void)signUserInWithUsername:(NSString *)username
                  andPassword: (NSString *)password {
    
    //check make sure device store_id matches the store_id of employee logging in
    NSString *devicePatronID = [[PFInstallation currentInstallation] objectForKey:@"patron_id"];
    NSLog(@"device patron ID is: %@", devicePatronID);
    
    PFObject *patronObject = [[PFUser currentUser] valueForKey:@"Patron"];
    [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
        if (!error){
            //check make sure device store_id matches the store_id of employee logging in
            NSString *userPatronID = [fetchedPatronObject objectId];
            NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
            if (![devicePatronID isEqualToString:userPatronID]){
                [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
                [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
                [[PFInstallation currentInstallation] saveInBackground];
                NSLog(@"device patron ID is now: %@", [[PFInstallation currentInstallation] objectForKey:@"patron_id"]);
            }
            
            User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
            if (localUserEntity == nil){
                localUserEntity = [User MR_createEntity];
            }
            
            [self setAppDelegateLocalUser:localUserEntity AndPatronObject:fetchedPatronObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoggingIn" object:self];
        }
        else {
            NSLog(@"error");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];

        }


    }];
        
    
}

-(void)registerUserInWithUsername:(NSString *)username
                      andPassword: (NSString *)password
                         andEmail: (NSString *)email
            andUserInfoDictionary: (NSDictionary *)userInfo {
    
    //make new user object
    __block PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = email;
    [newUser setValue:@"patron" forKey:@"account_type"];
    
    //sign up new user
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            NSString *username = [userInfo valueForKey:@"username"];
            NSString *email = [userInfo valueForKey:@"email"];
            NSString *fName = [userInfo valueForKey:@"fName"];
            NSString *lName = [userInfo valueForKey:@"lName"];
            NSString *birthday = @"01/01/1991";
            NSString *gender = [userInfo valueForKey:@"gender"];
                        
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id",username, @"username", email, @"email", gender, @"gender", fName, @"first_name", lName, @"last_name", nil];
            
            [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                if (!error){
                    User *localUserEntity = [User MR_createEntity];
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:createdPatronObject];
                    
                    [self setAppDelegateLocalUser:localUserEntity AndPatronObject:createdPatronObject];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoggingIn" object:self];


                    NSLog(@"user is %@", localUserEntity);
                }
                else{
                    NSLog(@"There was an ERROR: %@", error);
                    
                }
            }]; //end cloud code for register patron
            
        }
        
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];

            NSLog(@"There was an ERROR: %@", error);
        }

    }];

    
}

-(void)signUserWithFacebook {
    
    NSArray *permissionsArray = @[@"email", @"user_birthday", @"publish_actions"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];

            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (error){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];
        }
        else {
            
            PFObject *patronObject = [user objectForKey:@"Patron"];
            if (patronObject == nil){
                [self registerUserWithFacebook];
            }
            
            [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
                
                if (!error){
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    //set app delegate local user + patron object
                    User *localUserEntity =[User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
                    if (localUserEntity == nil){
                        localUserEntity = [User MR_createEntity];
                    }
                    [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
                    [appDelegate setLocalUser:localUserEntity];
                    [appDelegate setPatronObject:fetchedPatronObject];
                    
                    NSLog(@"punch code is %@", [[PFInstallation currentInstallation] valueForKey:@"punch_code"]);
                    
                    //make sure installation is set
                    NSString *userPatronID = [fetchedPatronObject objectId];
                    NSString *punch_code = [fetchedPatronObject valueForKey:@"punch_code"];
                    [[PFInstallation currentInstallation] setObject:userPatronID forKey:@"patron_id"];
                    [[PFInstallation currentInstallation] setObject:punch_code forKey:@"punch_code"];
                    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoggingIn" object:self];
                    }];
                    
                    [self setAppDelegateLocalUser:localUserEntity AndPatronObject:fetchedPatronObject];
                }
                else if (error){
                    NSLog(@"%@", error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];
                }
                
            }];
        }
    }];

}

-(void)registerUserWithFacebook {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"email", @"user_birthday", @"publish_actions"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"errorLoggingIn" object:self];

            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    NSString *facebookID = userData[@"id"];
                    NSString *fName = userData[@"first_name"];
                    NSString *lName = userData[@"last_name"];
                    NSString *email = userData[@"email"];
                    NSString *gender = userData[@"gender"];
                    NSString *birthday = userData[@"birthday"];
                    
                    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectId], @"user_id", [[PFUser currentUser]username], @"username", email, @"email", gender, @"gender", fName, @"first_name", birthday, @"birthday", lName, @"last_name", facebookID, @"facebook_id", nil];
                    
                    [PFCloud callFunctionInBackground:@"register_patron" withParameters:parameters block:^(id createdPatronObject, NSError *error) {
                        if (!error){
                            User *localUserEntity = [User MR_createEntity];
                            [localUserEntity setFromParseUserObject:[PFUser currentUser] andPatronObject:createdPatronObject];
                            NSLog(@"user is %@", localUserEntity);
                            
                            [self setAppDelegateLocalUser:localUserEntity AndPatronObject:createdPatronObject];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoggingIn" object:self];

                        }
                        else{
                            NSLog(@"There was an ERROR: %@", error);
                            
                        }
                    }]; //end register patron cloud code
                    
                    
                }
            }]; //end get user info
            
        }
    }]; //end login with facebook user

}

-(void)setAppDelegateLocalUser: (User *)localUser AndPatronObject:(PFObject*)patronObject{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setLocalUser:localUser];
    [appDelegate setPatronObject:patronObject];

}
@end
