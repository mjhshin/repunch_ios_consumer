//
//  RPMessageStatus.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPMessageStatus.h"
#import <Parse/PFObject+Subclass.h>

@implementation RPMessageStatus

@dynamic Message;
@dynamic redeem_available;
@dynamic is_read;

+ (NSString *)parseClassName
{
    return @"MessageStatus";
}

@end
