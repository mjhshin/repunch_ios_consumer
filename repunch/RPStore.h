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

@property (strong, readonly, atomic) NSString *store_name;
@property (strong, readonly, atomic) PFFile *thumbnail_image;
@property (strong, readonly, atomic) PFFile *cover_image;
@property (assign, readonly, atomic) BOOL active;
@property (assign, readonly, atomic) NSInteger punches_facebook;
@property (strong, readonly, atomic) NSArray *categories;
@property (strong, readonly, atomic) NSArray *rewards;
@property (strong, readonly, atomic) NSArray *store_locations;

// Unused (PFRelations also unused, not listed)
//@property (strong, readonly, atomic) NSString *country;
//@property (strong, readonly, atomic) NSString *first_name;
//@property (strong, readonly, atomic) NSString *last_name;
//@property (strong, readonly, atomic) NSString *owner_id;
//@property (strong, readonly, atomic) NSString *store_description;

+ (NSString *)parseClassName;

//- (void)updateStoreWithCompletionHandler:(StoreUpdateHandler)handler;
//- (void)updateStoreImageWithCompletionHander:(StoreImageUpdateHandler)handler;

@end
