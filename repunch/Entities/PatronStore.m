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


@implementation PatronStore

@dynamic punch_count;
@dynamic patron;
@dynamic store;

-(void)setFromPatronObject: (PFObject *)Patron andStoreEntity: (Store *)store andUserEntity: (User *)user{
    self.punch_count = [Patron valueForKey:@"punch_count"];
    self.store = store;
    self.patron = user;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];
    
}


@end
