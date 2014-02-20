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
