//
//  PatronStore.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/24/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PatronStore.h"
#import "Store.h"
#import "User.h"
#import <Parse/Parse.h>


@implementation PatronStore

@dynamic objectId;
@dynamic punch_count;
@dynamic patron_id;
@dynamic store_id;
@dynamic patron;
@dynamic store;

-(void)setFromPatronObject: (PFObject *)Patron andStoreEntity: (Store *)store andUserEntity: (User *)user andPatronStore:(PFObject *)patronStore {
    self.punch_count = [patronStore valueForKey:@"punch_count"];
    if (!self.punch_count) self.punch_count = [NSNumber numberWithInt:0];
    self.patron_id = user.patronId;
    self.store_id = store.objectId;
    self.store = store;
    self.patron = user;
    self.objectId = [patronStore objectId];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];
    
}

-(void)updateLocalEntityWithParseObject:(PFObject *)patronStoreObject{
    self.punch_count = [patronStoreObject valueForKey:@"punch_count"];
    if (!self.punch_count) self.punch_count = [NSNumber numberWithInt:0];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];

}

@end
