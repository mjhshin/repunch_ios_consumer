//
//  User.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "User.h"
#import "Message.h"
#import "Store.h"
#import <Parse/Parse.h>

@implementation User

@dynamic username;
@dynamic password;
@dynamic email;
@dynamic first_name;
@dynamic last_name;
@dynamic facebook_id;
@dynamic punch_code;
@dynamic received_messages;
@dynamic saved_stores;
@dynamic sent_messages;
@dynamic patronId;
@dynamic userId;

-(void)setFromParseUserObject: (PFUser *)user andPatronObject: (PFObject *)patron{
    self.username = user.username;
    self.password = user.password;
    self.email = user.email;
    self.first_name = [patron objectForKey:@"first_name"];
    self.last_name = [patron objectForKey:@"last_name"];
    self.facebook_id = [patron objectForKey:@"facebook_id"];
    self.punch_code = [patron objectForKey:@"punch_code"];
    self.patronId = [patron objectId];
    self.userId = [user objectId];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];

}

-(void)alreadyHasStoreSaved:(Store *)store{
    
}

@end
