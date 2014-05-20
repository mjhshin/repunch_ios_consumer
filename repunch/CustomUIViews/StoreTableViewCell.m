//
//  StoreTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreTableViewCell.h"
#import "RepunchUtils.h"

@implementation StoreTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (StoreTableViewCell *)cell
{
	StoreTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																	 owner:self
																   options:nil]
									   objectAtIndex:0];
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.contentView.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	
	UIView *invertedDivider = [[UIView alloc] initWithFrame:customCell.dividerView.frame];
	CGRect frame = invertedDivider.frame;
	frame.origin.x = 20;
	invertedDivider.frame = frame;
	invertedDivider.backgroundColor = [UIColor whiteColor];
	
	[selectedView addSubview:invertedDivider];
	
	customCell.selectedBackgroundView = selectedView;
	
    return customCell;
}

- (void)setPatronStoreNotAdded
{
	self.userInteractionEnabled = NO;
	self.rewardStatusIcon.hidden = YES;
	self.rewardPunches.textColor = [RepunchUtils repunchOrangeColor];
	self.rewardPunchesStatic.textColor = [RepunchUtils repunchOrangeColor];
}

- (void)setRewardUnlocked
{
	self.userInteractionEnabled = YES;
	self.rewardStatusIcon.hidden = NO;
	self.rewardStatusIcon.image = [UIImage imageNamed:@"RedeemCheckmark"];
	self.rewardPunches.textColor = [RepunchUtils repunchOrangeColor];
	self.rewardPunchesStatic.textColor = [RepunchUtils repunchOrangeColor];
}

- (void)setRewardLocked
{
	self.userInteractionEnabled = NO;
	self.rewardStatusIcon.hidden = NO;
	self.rewardStatusIcon.image = [UIImage imageNamed:@"reward_locked"];
	self.rewardPunches.textColor = [UIColor darkGrayColor];
	self.rewardPunchesStatic.textColor = [UIColor darkGrayColor];
}

+ (CGFloat)height
{
	return 150.0f;
}

@end
