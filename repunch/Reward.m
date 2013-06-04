//
//  Reward.m
//  repunch
//
//  Created by CambioLabs on 4/15/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "Reward.h"
#import "Retailer.h"


@implementation Reward

@dynamic reward_id;
@dynamic name;
@dynamic reward_description;
@dynamic required;
@dynamic redeem_count;
@dynamic place;

-(void) setFromParse:(PFObject *)pfObject
{
    self.reward_id = [pfObject objectForKey:@"id"];
    self.name = [pfObject objectForKey:@"title"];
    self.reward_description = [pfObject objectForKey:@"description"];
    self.required = [pfObject objectForKey:@"num_punches"];
    self.redeem_count = [pfObject objectForKey:@"redeem_count"];
}

@end
