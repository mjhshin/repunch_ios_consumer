//
//  Hour.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "Hour.h"
#import "Store.h"


@implementation Hour

@dynamic close_time;
@dynamic day;
@dynamic open_time;
@dynamic store;

- (void)setFromParse:(PFObject *)hour
{
    self.day = [hour objectForKey:@"day"];
    self.open_time = [hour objectForKey:@"open_time"];
    self.close_time = [hour objectForKey:@"close_time"];
}


@end
