//
//  Reward.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Store;

@interface Reward : NSManagedObject

@property (nonatomic, retain) NSNumber * punches;
@property (nonatomic, retain) NSString * reward_description;
@property (nonatomic, retain) NSString * reward_name;
@property (nonatomic, retain) Store *store;

-(void) setFromParse:(PFObject *)pfObject;
@end
