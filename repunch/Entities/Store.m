//
//  Store.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "Store.h"
#import "Category.h"
#import "Reward.h"
#import "Hour.h"
#import <Parse/Parse.h>

@implementation Store

@dynamic store_name;
@dynamic objectId;
@dynamic city;
@dynamic store_description;
@dynamic store_avatar;
@dynamic street;
@dynamic cross_streets;
@dynamic neighborhood;
@dynamic state;
@dynamic zip;
@dynamic country;
@dynamic phone_number;
@dynamic categories;
@dynamic hours;
@dynamic rewards;
@dynamic longitude;
@dynamic latitude;

-(void)setFromParseObject: (PFObject *)store{
    self.store_name = [store objectForKey:@"store_name"];
    self.objectId = [store objectForKey:@"objectId"];
    self.store_description = [store objectForKey:@"store_description"];
    /*
    PFFile *picFile = [store objectForKey:@"store_avatar"];
    [picFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        self.store_avatar = data;
    }];
     */
    self.store_avatar = [[store objectForKey:@"store_avatar"] getData];

    self.street = [store objectForKey:@"street"];
    if ([store objectForKey:@"cross_streets"] !=  [NSNull null]) self.cross_streets = [store objectForKey:@"cross_streets"];
    if ([store objectForKey:@"neighborhood"] !=  [NSNull null]) self.neighborhood = [store objectForKey:@"neighborhood"];
    self.state = [store objectForKey:@"state"];
    self.zip = [store objectForKey:@"zip"];
    self.country = [store objectForKey:@"country"];
    self.phone_number = [store objectForKey:@"phone_number"];
    self.city = [store objectForKey:@"city"];
    self.latitude = [(PFGeoPoint *)[store objectForKey:@"coordinates"] latitude];
    self.longitude = [(PFGeoPoint *)[store objectForKey:@"coordinates"] longitude];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *categories = [[NSArray alloc] initWithArray:[store objectForKey:@"categories"]];
    for (PFObject *category in categories) {
        Category *newCategory;
        newCategory = [Category MR_findFirstByAttribute:@"alias" withValue:[category objectForKey:@"alias"]];
        if (newCategory == nil) {
            newCategory = [Category MR_createInContext:localContext];
        }
        [newCategory addStoreObject:self];
        [newCategory setFromParse:category];
        [localContext MR_saveToPersistentStoreAndWait];
    }
    
    NSArray *hours = [[NSArray alloc] initWithArray:[store objectForKey:@"hours"]];
    for (PFObject *hour in hours) {
        Hour *newHour = [Hour MR_createInContext:localContext];
        [newHour setStore:self];
        [newHour setFromParse:hour];
        [localContext MR_saveToPersistentStoreAndWait];
    }
    
    NSArray *rewards = [[NSArray alloc] initWithArray:[store objectForKey:@"rewards"]];
    for (PFObject *reward in rewards) {
        Reward *newReward = [Reward MR_createInContext:localContext];
        [newReward setFromParse:reward];
        [localContext MR_saveToPersistentStoreAndWait];
    }
    
    [localContext MR_saveToPersistentStoreAndWait];

}


@end
