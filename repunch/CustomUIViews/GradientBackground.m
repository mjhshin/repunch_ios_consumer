//
//  GradientBackground.m
//  RepunchConsumer
//
//  Created by Michael Shin on 7/31/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "GradientBackground.h"

@implementation GradientBackground

+ (CAGradientLayer*) orangeGradient
{
	//DEPRECATED
	//Orange RGB: 0xf08c13
	//Gradient Alpha: 0xd9 -> 0xff
	
	//OFFICIAL GRADIENT
	//FFB940FF
	//F08C13FF
	
    UIColor *orange1 = [UIColor colorWithRed:(235/255.0) green:(165/255.0) blue:(44/255.0) alpha:1.0];
	UIColor *orange2 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:1.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)orange2.CGColor, orange1.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	
    return headerLayer;
}

+ (UIImage *) orangeButtonNormal:(UIButton *)button
{
	//Orange RGB: 0xf08c13
	//Gradient Alpha: 0xd9 -> 0xff
	
	UIColor *orange1 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:1.0];
	UIColor *orange2 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:(217/255.0)];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)orange1.CGColor, orange2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	headerLayer.frame = button.bounds;
	
	UIGraphicsBeginImageContext(headerLayer.frame.size);
	
	[headerLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

+ (UIImage *) orangeButtonHighlighted:(UIButton *)button
{
	//Orange Pressed RGB: 0xBF6804
	//Gradient Alpha: 0xc0 -> 0xff
	
	UIColor *orangeSelected1 = [UIColor colorWithRed:(160/255.0) green:(85/255.0) blue:(4/255.0) alpha:1.0];
	UIColor *orangeSelected2 = [UIColor colorWithRed:(160/255.0) green:(85/255.0) blue:(4/255.0) alpha:(192/255.0)];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)orangeSelected1.CGColor, orangeSelected2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	headerLayer.frame = button.bounds;
	
	UIGraphicsBeginImageContext(headerLayer.frame.size);
	
	[headerLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

+ (UIImage *) blackButtonNormal:(UIButton *)button
{
	//Black RGB: 0x000000
	
	UIColor *black1 = [UIColor colorWithRed:(112/255.0) green:(112/255.0) blue:(112/255.0) alpha:1.0];
    UIColor *black2 = [UIColor colorWithRed:(64/255.0) green:(64/255.0) blue:(64/255.0) alpha:1.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)black1.CGColor, black2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	headerLayer.frame = button.bounds;
	
	UIGraphicsBeginImageContext(headerLayer.frame.size);
	
	[headerLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

+ (UIImage *) blackButtonHighlighted:(UIButton *)button
{	
	UIColor *black1 = [UIColor colorWithRed:(88/255.0) green:(88/255.0) blue:(88/255.0) alpha:1.0];
    UIColor *black2 = [UIColor colorWithRed:(40/255.0) green:(40/255.0) blue:(40/255.0) alpha:1.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)black1.CGColor, black2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	headerLayer.frame = button.bounds;
	
	UIGraphicsBeginImageContext(headerLayer.frame.size);
	
	[headerLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

+ (UIImage *) greyDisabledButton:(UIButton *)button
{
	UIColor *black2 = [UIColor colorWithRed:(168/255.0) green:(168/255.0) blue:(168/255.0) alpha:1.0];
    UIColor *black1 = [UIColor colorWithRed:(136/255.0) green:(136/255.0) blue:(136/255.0) alpha:1.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)black1.CGColor, black2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	headerLayer.frame = button.bounds;
	
	UIGraphicsBeginImageContext(headerLayer.frame.size);
	
	[headerLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

@end
