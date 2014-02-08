//
//  RPPatronStore.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/7/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPPatronStore.h"
#import <Parse/PFObject+Subclass.h>

@implementation RPPatronStore

@dynamic pending_reward;
@dynamic all_time_punches;
@dynamic punch_count;

+ (NSString *)parseClassName
{
    return @"PatronStore";
}

@end
