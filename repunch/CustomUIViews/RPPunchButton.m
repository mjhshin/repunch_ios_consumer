//
//  RPPunchButton.m
//  RepunchConsumer
//
//  Created by Michael Shin on 4/22/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPPunchButton.h"
#import "RepunchUtils.h"

@implementation RPPunchButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initButton];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([[RepunchUtils repunchOrangeColor] CGColor]));
    CGContextFillPath(ctx);
}
*/
- (void)initButton
{
	self.adjustsImageWhenDisabled = NO;
	self.adjustsImageWhenHighlighted = YES;
	
	[self setImage:[UIImage imageNamed:@"tab_punch"] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"OrangeButton"] forState:UIControlStateNormal];
	//[self setBackgroundImage:[UIImage imageNamed:@"new_orange_button_pressed"] forState:UIControlStateHighlighted];
}

@end
