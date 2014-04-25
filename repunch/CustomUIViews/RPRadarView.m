//
//  RPRadarView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 4/24/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPRadarView.h"
#import "RepunchUtils.h"

#define kSpinAnimationKey @"SpinAnimationKey"
#define kSpinAnimationDuration 2.2f

@interface RPRadarView()

@property (strong, nonatomic) UIImageView *radarHand;

@end

@implementation RPRadarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder]) {
		[self initView];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([[RepunchUtils repunchOrangeColorWithAlpha:0.75f] CGColor]));
    CGContextFillPath(ctx);
}

- (void)initView
{
	self.backgroundColor = [UIColor clearColor];
	self.radarHand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluetooth_scanning"]];
	self.radarHand.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	self.contentMode = UIViewContentModeScaleToFill;
	[self addSubview:self.radarHand];
}

- (void)startAnimation
{
	CABasicAnimation *spinAnimation;
	spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	spinAnimation.fromValue = [NSNumber numberWithFloat:0];
	spinAnimation.toValue = [NSNumber numberWithFloat: 2*M_PI];;
	spinAnimation.duration = kSpinAnimationDuration;
	spinAnimation.repeatCount = HUGE_VALF;
	spinAnimation.removedOnCompletion = NO;
	[self.layer addAnimation:spinAnimation forKey:kSpinAnimationKey];
}

- (void)stopAnimation
{
	[self.layer removeAnimationForKey:kSpinAnimationKey];
}

@end
