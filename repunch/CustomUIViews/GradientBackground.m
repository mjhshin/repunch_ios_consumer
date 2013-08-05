//
//  GradientBackground.m
//  RepunchConsumer
//
//  Created by Michael Shin on 7/31/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "GradientBackground.h"

@implementation GradientBackground

//Blue gradient background
+ (CAGradientLayer*) orangeGradient {
	
	//Orange RGB: 0xf08c13
	//Gradient Alpha: 0xd9 -> 0xff
	
    UIColor *repunchOrange1 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:1.0];
	UIColor *repunchOrange2 = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:(217/255.0)];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)repunchOrange1.CGColor, repunchOrange2.CGColor, nil];
	
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
	
    return headerLayer;	
}

@end
