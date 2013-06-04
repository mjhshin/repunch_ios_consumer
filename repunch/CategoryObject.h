//
//  CategoryObject.h
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Retailer;

@interface CategoryObject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSSet *places;
@end

@interface CategoryObject (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Retailer *)value;
- (void)removePlacesObject:(Retailer *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

- (void)setFromParse:(PFObject *)category;

@end
