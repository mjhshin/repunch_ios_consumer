//
//  User.h
//  repunch
//
//  Created by CambioLabs on 4/15/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class Retailer, Message;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSDate * birth_date;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * is_dirty;
@property (nonatomic, retain) NSSet *my_places;
@property (nonatomic, retain) NSSet *messages;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMy_placesObject:(Retailer *)value;
- (void)removeMy_placesObject:(Retailer *)value;
- (void)addMy_places:(NSSet *)values;
- (void)removeMy_places:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)setFromParse:(PFUser *)user;
- (BOOL)hasPlace:(Retailer *)place;
@end
