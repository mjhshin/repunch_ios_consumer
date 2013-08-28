//
//  GradientBackground.h
//  RepunchConsumer
//
//  Created by Michael Shin on 7/31/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface GradientBackground : NSObject

+ (CAGradientLayer*) orangeGradient;

+ (UIImage *) orangeButtonNormal:(UIButton *)button;
+ (UIImage *) orangeButtonHighlighted:(UIButton *)button;

+ (UIImage *) blackButtonNormal:(UIButton *)button;
+ (UIImage *) blackButtonHighlighted:(UIButton *)button;

+ (UIImage *) greyDisabledButton:(UIButton *)button;

@end
