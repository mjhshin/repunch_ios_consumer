//
//  RPButton.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPButton.h"

@implementation RPButton {
	UIActivityIndicatorView *spinner;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder]) {
		[self initButton];
	}
	
	return self;
}

- (void)initButton
{
	self.layer.cornerRadius = 4;
	self.clipsToBounds = YES;
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.hidesWhenStopped = YES;
	
	spinner.frame = self.bounds;
	[self addSubview:spinner];
	
	[self setEnabled];
}

- (void)setEnabled
{
	self.enabled = YES;
	
	[self setBackgroundImage:[UIImage imageNamed:@"orange_gradient_button"] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"orange_gradient_button_highlighted"] forState:UIControlStateHighlighted];
}

- (void)setDisabled
{
	self.enabled = NO;
	
	[self setBackgroundImage:[UIImage imageNamed:@"grey_button"] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"grey_button"] forState:UIControlStateHighlighted];
}

- (void)setTitle:(NSString *)text
{
	[self setTitle:text forState:UIControlStateNormal];
}

- (void)startSpinner
{
	self.titleLabel.alpha = 0.0f;
	[spinner startAnimating];
}

- (void)stopSpinner
{
	self.titleLabel.alpha = 1.0f;
	[spinner stopAnimating];
}

@end
