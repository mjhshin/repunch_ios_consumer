//
//  AttachmentTableViewCell.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/19/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "AttachmentTableViewCell.h"
#import "OfferBorderView.h"
#import "GiftBorderView.h"
#import "RepunchUtils.h"

@implementation AttachmentTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (AttachmentTableViewCell *)cell
{
	return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
										  owner:self
										options:nil] objectAtIndex:0];
}

- (void)awakeFromNib
{
    self.frame = [RepunchUtils frameForViewWithInitialFrame:self.frame
                                          withDynamicLabels:@[self.title, self.rewardTitle, self.rewardDescription]
                                           andInitialHights:@[@(CGRectGetHeight(self.title.frame)),
                                                              @(CGRectGetHeight(self.rewardTitle.frame)),
                                                              @(CGRectGetHeight(self.rewardDescription.frame))]];
}

- (void)setOfferBorder
{
	self.titleVerticalPaddingConstraint.constant = 26.0f;
	
	[self.contentView setNeedsLayout];
	[self.contentView layoutIfNeeded];
	
	OfferBorderView *background = [[OfferBorderView alloc] init];
	background.frame = self.borderView.bounds;
	[self.borderView addSubview:background];
}

- (void)setGiftBorder
{
	self.titleVerticalPaddingConstraint.constant = 80.0f;
	
	[self.contentView setNeedsLayout];
	[self.contentView layoutIfNeeded];
	
	GiftBorderView *background = [[GiftBorderView alloc] init];
	background.frame = self.borderView.bounds;
	[self.borderView addSubview:background];
}


@end
