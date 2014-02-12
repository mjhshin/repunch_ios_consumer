//
//  StoreDetailTableViewCell.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreDetailTableViewCell.h"
#import "RepunchUtils.h"

@implementation StoreDetailTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (StoreDetailTableViewCell *)cell
{
	StoreDetailTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																		  owner:self
																		options:nil]
											objectAtIndex:0];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	customCell.selectedBackgroundView = selectedView;
	
	customCell.locationImage.layer.cornerRadius = 10.0;
	customCell.locationImage.layer.masksToBounds = YES;
	
	return customCell;
}

@end
