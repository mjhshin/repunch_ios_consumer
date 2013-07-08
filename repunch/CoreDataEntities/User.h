//
//  User.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Message, PatronStore;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * patronId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSString * punch_code;
@property (nonatomic, retain) NSSet *received_messages;
@property (nonatomic, retain) NSSet *saved_stores;
@property (nonatomic, retain) NSSet *sent_messages;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addReceived_messagesObject:(Message *)value;
- (void)removeReceived_messagesObject:(Message *)value;
- (void)addReceived_messages:(NSSet *)values;
- (void)removeReceived_messages:(NSSet *)values;

- (void)addSaved_storesObject:(PatronStore *)value;
- (void)removeSaved_storesObject:(PatronStore *)value;
- (void)addSaved_stores:(NSSet *)values;
- (void)removeSaved_stores:(NSSet *)values;

- (void)addSent_messagesObject:(Message *)value;
- (void)removeSent_messagesObject:(Message *)value;
- (void)addSent_messages:(NSSet *)values;
- (void)removeSent_messages:(NSSet *)values;

-(void)setFromParseUserObject: (PFUser *)user andPatronObject: (PFObject *)patron;

-(BOOL)alreadyHasStoreSaved:(NSString *)storeId;

-(NSString *)fullName;

@end
