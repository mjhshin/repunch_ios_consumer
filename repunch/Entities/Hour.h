//
//  Hour.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Store;

@interface Hour : NSManagedObject

@property (nonatomic, retain) NSString * close_time;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSString * open_time;
@property (nonatomic, retain) Store *store;
- (void)setFromParse:(PFObject *)hour;
@end
