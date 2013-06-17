//
//  Retailer.m
//  repunch
//
//  Created by Gwendolyn Weston on 6/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "Retailer.h"
#import "CategoryObject.h"
#import "HoursObject.h"
#import "Reward.h"


@implementation Retailer

@dynamic address;
@dynamic city;
@dynamic country_code;
@dynamic cross_street;
@dynamic distance;
@dynamic image_url;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic neighborhood;
@dynamic num_punches;
@dynamic phone;
@dynamic postal_code;
@dynamic state;
@dynamic categories;
@dynamic hours;
@dynamic rewards;

- (void)setFromParse:(PFObject *)pfObject
{
    self.name = [pfObject objectForKey:@"store_name"];
    self.phone = [pfObject objectForKey:@"phone_number"];
    self.address = [pfObject objectForKey:@"street"];
    self.cross_street = [pfObject objectForKey:@"cross_streets"];
    self.neighborhood = [pfObject objectForKey:@"neighborhood"];
    self.city = [pfObject objectForKey:@"city"];
    self.state = [pfObject objectForKey:@"state"];
    self.country_code = [pfObject objectForKey:@"country"];
    self.postal_code = [NSString stringWithFormat:@"%@",[pfObject objectForKey:@"zip"]];
    self.image_url = [[pfObject objectForKey:@"store_avatar"] getData];
    self.latitude = [NSNumber numberWithDouble:[(PFGeoPoint *)[pfObject objectForKey:@"coordinates"] latitude]];
    self.longitude = [NSNumber numberWithDouble:[(PFGeoPoint *)[pfObject objectForKey:@"coordinates"] longitude]];

    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *categories = [[[NSArray alloc] initWithArray:[pfObject objectForKey:@"categories"]] autorelease];
    for (PFObject *category in categories) {
        CategoryObject *newCategory;
        newCategory = [CategoryObject MR_findFirstByAttribute:@"name" withValue:[category objectForKey:@"name"]];
        if (newCategory == nil) {
            newCategory = [CategoryObject MR_createInContext:localContext];
        }
        [newCategory addPlacesObject:self];
        [newCategory setFromParse:category];
        [localContext MR_saveToPersistentStoreAndWait];
    }
    
    NSArray *hours = [[[NSArray alloc] initWithArray:[pfObject objectForKey:@"hours"]] autorelease];
    for (PFObject *hour in hours) {
        HoursObject *newHour;
        newHour = [HoursObject MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"place == %@ AND day == %@",self,[hour objectForKey:@"day"]]];
        if (newHour == nil) {
            newHour = [HoursObject MR_createInContext:localContext];
        }
        [newHour setPlace:self];
        [newHour setFromParse:hour];
        [localContext MR_saveToPersistentStoreAndWait];
    }
    
    NSArray *rewards = [[[NSArray alloc] initWithArray:[pfObject objectForKey:@"rewards"]] autorelease];
    for (PFObject *reward in rewards) {
        Reward *newReward;
        newReward = [Reward MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"place == %@ AND name == %@",self,[reward objectForKey:@"title"]]];
        if (newReward == nil) {
            newReward = [Reward MR_createInContext:localContext];
        }
        [newReward setFromParse:reward];
        [newReward setPlace:self];
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

@end
