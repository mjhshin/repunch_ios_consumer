//
//  OfferBorderView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 1/28/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "OfferBorderView.h"
#import "RepunchUtils.h"

@implementation OfferBorderView

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
	UIImageView *scissors = [[UIImageView alloc] initWithFrame:CGRectMake(50, 0, 48, 24)];
	scissors.image = [UIImage imageNamed:@"scissors"];
	scissors.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:scissors];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat scissorsHeightOffset = scissors.frame.size.height/2;
	CGFloat offset = 4;
	
	// set width to 4 and color to orange
    CGContextSetLineWidth(context, 6);
    CGContextSetStrokeColorWithColor(context, [RepunchUtils lightRepunchOrangeColor].CGColor);
    
	// pattern where dash = 9, gap = 4
	CGFloat dashArray[] = {12,6};
	
	// phase = 0, dashArray elements = 2
    CGContextSetLineDash(context, 0, dashArray, 2);
    
	// left edge
	CGContextMoveToPoint(context, 0, offset + scissorsHeightOffset);
    CGContextAddLineToPoint(context, 0, rect.size.height - offset);
    CGContextStrokePath(context);
	
	// right edge
	CGContextMoveToPoint(context, rect.size.width, offset + scissorsHeightOffset);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height - offset);
    CGContextStrokePath(context);
	
	// bottom edge
	CGContextMoveToPoint(context, offset, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width - offset, rect.size.height);
    CGContextStrokePath(context);
	
	CGContextSetLineWidth(context, 3); //for some reason width needs to be halved for top edges to maintain same width. WTF?
	
	// left top edge
	CGContextMoveToPoint(context, offset, scissorsHeightOffset);
	CGContextAddLineToPoint(context, scissors.frame.origin.x - 4, scissorsHeightOffset);
    CGContextStrokePath(context);
	
	// right top edge
	CGContextMoveToPoint(context, scissors.frame.origin.x + scissors.frame.size.width - 6, scissorsHeightOffset);
	CGContextAddLineToPoint(context, rect.size.width - offset, scissorsHeightOffset);
    CGContextStrokePath(context);
}

@end
