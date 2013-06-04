//
//  HoursObject.h
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Retailer;

@interface HoursObject : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSString * close_time;
@property (nonatomic, retain) NSString * open_time;
@property (nonatomic, retain) Retailer *place;

- (void) setFromParse:(PFObject *)hour;

@end
