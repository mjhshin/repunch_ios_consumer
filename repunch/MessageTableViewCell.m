//
//  MessageTableViewCell.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/19/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (MessageTableViewCell *)cell
{
	return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
										  owner:self
										options:nil] objectAtIndex:0];
}

@end
