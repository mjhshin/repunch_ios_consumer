//
//  PatronStore.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/24/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>


@class Store, User;

@interface PatronStore : NSManagedObject

@property (nonatomic, retain) NSNumber * punch_count;
@property (nonatomic, retain) User *patron;
@property (nonatomic, retain) Store *store;

-(void)setFromPatronObject: (PFObject *)Patron andStoreEntity: (Store *)store andUserEntity: (User *)user;

@end
