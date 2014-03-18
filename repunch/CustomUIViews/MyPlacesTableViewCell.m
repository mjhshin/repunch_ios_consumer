//
//  MyPlacesTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesTableViewCell.h"
#import "RepunchUtils.h"

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
	MyPlacesTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																	owner:self
																  options:nil]
									  objectAtIndex:0];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	customCell.selectedBackgroundView = selectedView;
	
	customCell.storeImage.layer.cornerRadius = 8.0;
	customCell.storeImage.layer.masksToBounds = YES;
	
	return customCell;
}

@end
