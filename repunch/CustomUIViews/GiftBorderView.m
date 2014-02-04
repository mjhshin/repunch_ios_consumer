//
//  GiftBorderView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 1/29/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "GiftBorderView.h"
#import "RepunchUtils.h"

@implementation GiftBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	UIImageView *giftBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 70)];
	giftBox.image = [UIImage imageNamed:@"gift_box"];
	giftBox.contentMode = UIViewContentModeScaleToFill;
	[self addSubview:giftBox];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat giftBoxHeight = giftBox.frame.size.height - 10;
	CGFloat horizontalPadding = 10;
	
	// set width to 4 and color to orange
    CGContextSetLineWidth(context, 3);
    CGContextSetStrokeColorWithColor(context, [RepunchUtils lightRepunchOrangeColor].CGColor);
    
	// left edge
	CGContextMoveToPoint(context, horizontalPadding, giftBoxHeight);
    CGContextAddLineToPoint(context, horizontalPadding, rect.size.height);
    CGContextStrokePath(context);
	
	// right edge
	CGContextMoveToPoint(context, rect.size.width - horizontalPadding, giftBoxHeight);
	CGContextAddLineToPoint(context, rect.size.width - horizontalPadding, rect.size.height);
    CGContextStrokePath(context);
	
	CGContextSetLineWidth(context, 6); // necessary to set same width for bottom. WTF?
	
	// bottom edge
	CGContextMoveToPoint(context, horizontalPadding, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width - horizontalPadding, rect.size.height);
    CGContextStrokePath(context);
}

@end
