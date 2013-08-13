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
	//Orange RGB: 0xf08c13
	//Gradient Alpha: 0xd9 -> 0xff
	
    UIColor *orange1 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:1.0];
	UIColor *orange2 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:(217/255.0)];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)orange1.CGColor, orange2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	
    return headerLayer;	
}

+ (CAGradientLayer*) orangeGradientPressed
{
	//Orange Pressed RGB: 0xBF6804
	//Gradient Alpha: 0xc0 -> 0xff
	
    UIColor *orangeSelected1 = [UIColor colorWithRed:(191/255.0) green:(104/255.0) blue:(4/255.0) alpha:1.0];
	UIColor *orangeSelected2 = [UIColor colorWithRed:(191/255.0) green:(104/255.0) blue:(4/255.0) alpha:(192/255.0)];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)orangeSelected1.CGColor, orangeSelected2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	
    return headerLayer;
}

+ (CAGradientLayer *) blackButtonGradient
{
	//Black RGB: 0x000000
	
	UIColor *black1 = [UIColor colorWithRed:(96/255.0) green:(96/255.0) blue:(96/255.0) alpha:1.0];
    UIColor *black2 = [UIColor colorWithRed:(48/255.0) green:(48/255.0) blue:(48/255.0) alpha:1.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)black1.CGColor, black2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	
    return headerLayer;
}

@end
