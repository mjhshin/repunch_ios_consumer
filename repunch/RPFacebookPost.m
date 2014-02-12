//
//  RPFacebookPost.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPFacebookPost.h"
#import <Parse/PFObject+Subclass.h>

@implementation RPFacebookPost

@dynamic posted;
@dynamic Patron;
@dynamic reward;

+ (NSString *)parseClassName
{
    return @"FacebookPost";
}

@end
