//
//  RewardTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RewardTableViewCell.h"
#import "RepunchUtils.h"

@implementation RewardTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (RewardTableViewCell *)cell
{
	RewardTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																	 owner:self
																   options:nil]
									   objectAtIndex:0];
	// add shadow
	[customCell.whiteContentView.layer setShadowColor:[UIColor darkGrayColor].CGColor];
	[customCell.whiteContentView.layer setShadowOpacity:0.7];
	[customCell.whiteContentView.layer setShadowRadius:1.0];
	[customCell.whiteContentView.layer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.contentView.frame];
	selectedView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UIView *selectedContentView = [[UIView alloc] initWithFrame:customCell.whiteContentView.frame];
	selectedContentView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	
	[selectedView addSubview:selectedContentView];
	
	customCell.selectedBackgroundView = selectedView;
	
    return customCell;
}

@end
