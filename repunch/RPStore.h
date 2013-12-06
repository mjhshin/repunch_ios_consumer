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

#define kStoreFetchCount 25


@interface RPStore : PFObject <PFSubclassing>

@property (assign, readonly, atomic) BOOL active;

@property (strong, readonly, atomic) NSString *store_name;
@property (strong, readonly, atomic) UIImage *avatar;
@property (strong, readonly, atomic) NSArray *rewards;
@property (strong, readonly, atomic) NSArray *hours;
@property (strong, readonly, atomic) NSString* address;
@property (strong, readonly, atomic) RPStoreHours *hoursManager;

+ (NSString *)parseClassName;

- (void)updateStoreInfoWithCompletionHandler:(StoreUpdateHandler)handler;
- (void)updateStoreAvatarWithCompletionHander:(StoreUpdateAvatarHandler)handler; // store must have data available
@end
