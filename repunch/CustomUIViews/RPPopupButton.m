//
//  RPPopupBottom.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/24/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPPopupButton.h"

#define ANIMATION_DELAY 0.15
#define ANIMATION_DURATION 0.2

@implementation RPPopupButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder]) {
		[self initButton];
	}
	
	return self;
}

- (void)initButton
{
	self.enabled = NO;
	self.hidden = YES;
	
	[self setBackgroundImage:[UIImage imageNamed:@"button_popup_grey"]
					forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"button_popup_grey_highlighted"]
					forState:UIControlStateHighlighted];
}

- (void)showButton // Slide onto screen
{
	CGRect startRect = self.frame;
	startRect.origin.y += startRect.size.height;
	self.frame = startRect;
	
	self.hidden = NO;
	
	[UIView animateWithDuration:ANIMATION_DURATION
						  delay:ANIMATION_DELAY
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect endRect = self.frame;
						 endRect.origin.y -= endRect.size.height;
						 self.frame = endRect;
					 }
					 completion:^(BOOL finished) {
						 self.enabled = YES;
					 }];
}

- (void)hideButton // Slide off screen
{
	[UIView animateWithDuration:ANIMATION_DURATION
						  delay:ANIMATION_DELAY
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect endRect = self.frame;
						 endRect.origin.y += endRect.size.height;
						 self.frame = endRect;
					 }
					 completion:^(BOOL finished) {
						 self.enabled = NO;
					 }];
}

@end
