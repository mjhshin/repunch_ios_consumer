//
//  RPStoreLocation.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RPStoreLocation.h"
#import <Parse/PFObject+Subclass.h>
#import "DataManager.h"

@interface RPStoreLocation()

@end

@implementation RPStoreLocation

#pragma mark - properties synthesize

@synthesize avatar;
@synthesize hoursManager;
@synthesize m_storeHoursManager;

@dynamic hours;
@dynamic street;
@dynamic neighborhood;
@dynamic state;
@dynamic city;
@dynamic zip;
@dynamic phone_number;
@dynamic cover_image;
@dynamic coordinates;
@dynamic Store;

#pragma mark - Parse

+ (NSString *)parseClassName
{
    return @"StoreLocation";
}

- (NSString *)formattedAddress
{
    NSString *street = self.street;
    
    if( !IS_NIL(self.neighborhood) ) {
        street = [[street stringByAppendingString:@"\n"] stringByAppendingString:self.neighborhood];
	}
    
    street = [street stringByAppendingString:[NSString stringWithFormat:@"\n%@, %@ %@", self.city, self.state, self.zip]];
    
    return street;
}

- (RPStoreHours *)hoursManager
{
    if (!m_storeHoursManager) {
        m_storeHoursManager = [[RPStoreHours alloc] initWithStoreHoursArray:self.hours];
    }
    return m_storeHoursManager;
}

@end