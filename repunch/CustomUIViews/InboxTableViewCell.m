//
//  InboxTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxTableViewCell.h"

@implementation InboxTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (InboxTableViewCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier] owner:self options:nil] objectAtIndex:0];
}

@end
