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
@property (strong, readonly, atomic) PFFile *store_avatar;
@property (assign, readonly, atomic) BOOL active;
@property (assign, readonly, atomic) BOOL punches_facebook;
@property (strong, readonly, atomic) NSArray *categories;
@property (strong, readonly, atomic) NSArray *rewards;

@property (strong, readonly, atomic) PFRelation *StoreLocations;

// Not Inherited
@property (strong, readonly, atomic) UIImage *avatar;

// Unused (PFRelations also unused, not listed)
//@property (strong, readonly, atomic) NSString *country;
//@property (strong, readonly, atomic) NSString *first_name;
//@property (strong, readonly, atomic) NSString *last_name;
//@property (strong, readonly, atomic) NSString *owner_id;
//@property (strong, readonly, atomic) NSString *store_description;

+ (NSString *)parseClassName;

- (void)updateStoreAvatarWithCompletionHander:(StoreAvatarUpdateHandler)handler;

@end
