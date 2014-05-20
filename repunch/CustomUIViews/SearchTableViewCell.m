//
//  SearchTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "RepunchUtils.h"

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
	SearchTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																	 owner:self
																   options:nil]
									   objectAtIndex:0];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	customCell.selectedBackgroundView = selectedView;
	
	customCell.storeImage.layer.cornerRadius = 5.0;
	customCell.storeImage.layer.masksToBounds = YES;
	
	return customCell;
}

@end
