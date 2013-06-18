//
//  Store.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "Store.h"
#import <Parse/Parse.h>

@implementation Store

@dynamic store_name;
@dynamic objectId;
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

-(void)setFromParseObject: (PFObject *)store{
    self.store_name = [store objectForKey:@"store_name"];
    self.objectId = [store objectForKey:@"objectId"];
    self.store_description = [store objectForKey:@"store_description"];
    self.store_avatar = [store objectForKey:@"store_avatar"];
    self.street = [store objectForKey:@"street"];
    self.cross_streets = [store objectForKey:@"cross_streets"];
    self.neighborhood = [store objectForKey:@"neighborhood"];
    self.state = [store objectForKey:@"state"];
    self.zip = [store objectForKey:@"zip"];
    self.country = [store objectForKey:@"country"];
    self.phone_number = [store objectForKey:@"phone_number"];
    self.categories = [store objectForKey:@"categories"];
    self.hours = [store objectForKey:@"hours"];
    self.rewards = [store objectForKey:@"rewards"];
}


@end
