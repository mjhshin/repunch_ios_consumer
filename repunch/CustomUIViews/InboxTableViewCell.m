//
//  InboxTableViewCell.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxTableViewCell.h"
#import "RepunchUtils.h"

@implementation InboxTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (InboxTableViewCell *)cell
{
	InboxTableViewCell *customCell = [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
																	owner:self
																  options:nil]
									  objectAtIndex:0];
	
	
	
	UIView *selectedView = [[UIView alloc] initWithFrame:customCell.frame];
	selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
	customCell.selectedBackgroundView = selectedView;
	
	return customCell;
}

- (void)setMessageRead
{
	self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.senderName.font = [RepunchUtils repunchFontWithSize:17 isBold:NO];
	self.dateSent.font = [RepunchUtils repunchFontWithSize:14 isBold:NO];
	self.dateSent.textColor = [UIColor darkGrayColor];
}

- (void)setMessageUnread
{
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.senderName.font = [RepunchUtils repunchFontWithSize:17 isBold:YES];
	self.dateSent.font = [RepunchUtils repunchFontWithSize:14 isBold:YES];
	self.dateSent.textColor = [RepunchUtils repunchOrangeColor];
}

@end
