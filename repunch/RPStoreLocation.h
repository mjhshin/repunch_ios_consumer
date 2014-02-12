//
//  RPStoreLocation.h
//  RepunchConsumer
//
//  Created by Michael Shin on 12/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPConstants.h"
#import "RPStoreHours.h"
#import "NSDate+Additions.h"
#import "RPStoreHours.h"
#import "RPStore.h"

@interface RPStoreLocation : PFObject <PFSubclassing>

// Info
@property (strong, readonly, atomic) PFFile *cover_image;
@property (strong, readonly, atomic) PFGeoPoint *coordinates;
@property (strong, readonly, atomic) NSArray *hours;

// Address
@property (strong, readonly, atomic) NSString *street;
@property (strong, readonly, atomic) NSString *neighborhood;
@property (strong, readonly, atomic) NSString *state;
@property (strong, readonly, atomic) NSString *city;
@property (strong, readonly, atomic) NSString *zip;
@property (strong, readonly, atomic) NSString *phone_number;

@property (strong, readonly, atomic) RPStore *Store;

// Not Inherited
@property (strong, readonly, atomic) UIImage *avatar;
@property (strong, readonly, atomic) NSString* formattedAddress;
@property (strong, readonly, atomic) RPStoreHours *hoursManager;
@property (strong, atomic) RPStoreHours *m_storeHoursManager;

+ (NSString *)parseClassName;

//- (void)updateStoreLocationWithCompletionHandler:(StoreLocationUpdateHandler)handler;

@end
