//
//  StoreDetailTableViewCell.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationsTableViewCell.h"
#import "RepunchUtils.h"

@implementation LocationsTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (LocationsTableViewCell *)cell
{
	LocationsTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																		  owner:self
																		options:nil]
											objectAtIndex:0];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	customCell.selectedBackgroundView = selectedView;
	
	return customCell;
}

@end
