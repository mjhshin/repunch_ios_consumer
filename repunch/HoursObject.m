//
//  HoursObject.m
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "HoursObject.h"
#import "Retailer.h"


@implementation HoursObject

@dynamic day;
@dynamic close_time;
@dynamic open_time;
@dynamic place;

- (void)setFromParse:(PFObject *)hour
{
    self.day = [hour objectForKey:@"day"];
    self.open_time = [hour objectForKey:@"open_time"];
    self.close_time = [hour objectForKey:@"close_time"];
}

@end
