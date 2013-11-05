//
//  MyPlacesTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesTableViewCell.h"

@implementation MyPlacesTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (MyPlacesTableViewCell *)cell
{
    return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier] owner:self options:nil] objectAtIndex:0];
}

@end
