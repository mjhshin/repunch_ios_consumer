//
//  Hour.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Store;

@interface Hour : NSManagedObject

@property (nonatomic, retain) NSNumber * close_time;
@property (nonatomic, retain) NSString * open_time;
@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSSet *stores;
@end

@interface Hour (CoreDataGeneratedAccessors)

- (void)addStoresObject:(Store *)value;
- (void)removeStoresObject:(Store *)value;
- (void)addStores:(NSSet *)values;
- (void)removeStores:(NSSet *)values;

@end
