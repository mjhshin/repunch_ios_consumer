//
//  RPPatron.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/7/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPPatron.h"
#import <Parse/PFObject+Subclass.h>

@implementation RPPatron

@dynamic date_of_birth;
@dynamic facebook_id;
@dynamic first_name;
@dynamic last_name;
@dynamic gender;
@dynamic punch_code;

- (NSString *)full_name
{
	return [NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name];
}

+ (NSString *)parseClassName
{
    return @"Patron";
}

@end
