//
//  Store.h
//  Repunch
//
//  Created by Emil on 9/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPConstants.h"
#import "RPStoreHours.h"
#import "NSDate+Additions.h"
#import "RPStoreHours.h"

@interface RPStore : PFObject <PFSubclassing>

// Info
@property (strong, readonly, atomic) NSString *store_name;
@property (assign, readonly, atomic) BOOL active;
@property (assign, readonly, atomic) BOOL punches_facebook;
@property (strong, readonly, atomic) PFFile *store_avatar;
@property (strong, readonly, atomic) PFGeoPoint *coordinates;
@property (strong, readonly, atomic) NSArray *categories;
@property (strong, readonly, atomic) NSArray *rewards;
@property (strong, readonly, atomic) NSArray *hours;

// Address
@property (strong, readonly, atomic) NSString *street;
@property (strong, readonly, atomic) NSString *cross_streets;
@property (strong, readonly, atomic) NSString *neighborhood;
@property (strong, readonly, atomic) NSString *state;
@property (strong, readonly, atomic) NSString *city;
@property (strong, readonly, atomic) NSString *zip;
@property (strong, readonly, atomic) NSString *phone_number;

// Unused (PFRelations also unused, not listed)
//@property (strong, readonly, atomic) NSString *country;
//@property (strong, readonly, atomic) NSString *first_name;
//@property (strong, readonly, atomic) NSString *last_name;
//@property (strong, readonly, atomic) NSString *owner_id;
//@property (strong, readonly, atomic) NSString *store_description;

// Not Inherited
@property (strong, readonly, atomic) UIImage *avatar;
@property (strong, readonly, atomic) NSString* formattedAddress;
@property (strong, readonly, atomic) RPStoreHours *hoursManager;
@property (strong, atomic) RPStoreHours *m_storeHoursManager;

+ (NSString *)parseClassName;

- (void)updateStoreInfoWithCompletionHandler:(StoreUpdateHandler)handler;
- (void)updateStoreAvatarWithCompletionHander:(StoreAvatarUpdateHandler)handler; // store must have data available

@end
