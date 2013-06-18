//
//  Store.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>


@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * store_name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * store_description;
@property (nonatomic, retain) NSData * store_avatar;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * cross_streets;
@property (nonatomic, retain) NSString * neighborhood;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * phone_number;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *hours;
@property (nonatomic, retain) NSManagedObject *rewards;
@end

@interface Store (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(NSManagedObject *)value;
- (void)removeCategoriesObject:(NSManagedObject *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addHoursObject:(NSManagedObject *)value;
- (void)removeHoursObject:(NSManagedObject *)value;
- (void)addHours:(NSSet *)values;
- (void)removeHours:(NSSet *)values;

-(void)setFromParseObject: (PFObject *)store;

@end
