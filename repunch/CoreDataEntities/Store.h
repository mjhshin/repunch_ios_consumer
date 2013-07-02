//
//  Store.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/28/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Category, Hour, Reward;

@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * cross_streets;
@property double latitude;
@property double longitude;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * phone_number;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSData * store_avatar;
@property (nonatomic, retain) NSString * store_name;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *hours;
@property (nonatomic, retain) NSSet *rewards;
@end

@interface Store (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addHoursObject:(Hour *)value;
- (void)removeHoursObject:(Hour *)value;
- (void)addHours:(NSSet *)values;
- (void)removeHours:(NSSet *)values;

- (void)addRewardsObject:(Reward *)value;
- (void)removeRewardsObject:(Reward *)value;
- (void)addRewards:(NSSet *)values;
- (void)removeRewards:(NSSet *)values;

-(void)setFromParseObject: (PFObject *)store;

@end
