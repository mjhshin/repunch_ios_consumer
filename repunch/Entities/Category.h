//
//  Category.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Store;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *store;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addStoreObject:(Store *)value;
- (void)removeStoreObject:(Store *)value;
- (void)addStore:(NSSet *)values;
- (void)removeStore:(NSSet *)values;

- (void) setFromParse:(id)category;

@end
