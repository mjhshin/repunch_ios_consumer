//
//  SearchTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (SearchTableViewCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier] owner:self options:nil] objectAtIndex:0];
}

@end
