//
//  Reward.h
//  repunch
//
//  Created by CambioLabs on 4/15/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Retailer;

@interface Reward : NSManagedObject

@property (nonatomic, retain) NSString * reward_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reward_description;
@property (nonatomic, retain) NSNumber * required;
@property (nonatomic, retain) NSNumber * redeem_count;
@property (nonatomic, retain) Retailer * place;

- (void)setFromParse:(PFObject *)pfObject;

@end
