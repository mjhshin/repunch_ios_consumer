//
//  Reward.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "Reward.h"
#import "Store.h"


@implementation Reward

@dynamic punches;
@dynamic reward_description;
@dynamic reward_name;
@dynamic store;
@dynamic objectId;


-(void) setFromParse:(PFObject *)pfObject
{
    self.reward_name = [pfObject objectForKey:@"reward_name"];
    self.reward_description = [pfObject objectForKey:@"description"];
    self.punches = [NSNumber numberWithDouble:[[pfObject objectForKey:@"punches"] doubleValue]];
    self.objectId = [pfObject objectForKey:@"reward_id"];
}

@end
