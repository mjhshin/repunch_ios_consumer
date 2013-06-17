//
//  Retailer.h
//  repunch
//
//  Created by Gwendolyn Weston on 6/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CategoryObject, HoursObject, Reward;

@interface Retailer : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country_code;
@property (nonatomic, retain) NSString * cross_street;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSData * image_url;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSNumber * num_punches;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * postal_code;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *hours;
@property (nonatomic, retain) NSSet *rewards;
@end

@interface Retailer (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(CategoryObject *)value;
- (void)removeCategoriesObject:(CategoryObject *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addHoursObject:(HoursObject *)value;
- (void)removeHoursObject:(HoursObject *)value;
- (void)addHours:(NSSet *)values;
- (void)removeHours:(NSSet *)values;

- (void)addRewardsObject:(Reward *)value;
- (void)removeRewardsObject:(Reward *)value;
- (void)addRewards:(NSSet *)values;
- (void)removeRewards:(NSSet *)values;

@end
