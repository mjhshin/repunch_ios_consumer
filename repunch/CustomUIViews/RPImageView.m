//
//  RPImageView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPImageView.h"

@implementation RPImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self)
	{
        // Initialization code
    }
	
    return self;
}

- (void)setImageWithAnimation:(UIImage *)newImage
{
	CATransition *transition = [CATransition animation];
	transition.duration = 1.0f;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	
	[self.layer addAnimation:transition forKey:nil];
	
	self.image = newImage;
}

@end
