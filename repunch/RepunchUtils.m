//
//  RepunchUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SIAlertView.h"
#import "RepunchUtils.h"
#import "Reachability.h"
#import "RPCustomAlertController.h"

@implementation RepunchUtils

+ (BOOL)isConnectionAvailable
{
	Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
	return (status != NotReachable);
}

+ (void)showCustomDropdownView:(UIView *)parentView withMessage:(NSString *)message
{
	[self showNavigationBarDropdownView:parentView withMessage:message];
}

+ (void)showDefaultDropdownView:(UIView *)parentView
{
	[self showNavigationBarDropdownView:parentView withMessage:nil];
}

+ (void)showDialogWithTitle:(NSString *)title withMessage:(NSString *)message
{
    [RPCustomAlertController alertWithTitle:title andMessage:message];
}

+ (void)showPunchCode:(NSString *)punchCode
{
    [RPCustomAlertController alertWithTitle:@"Your Punch Code" andMessage:punchCode];
}

+ (void)showNavigationBarDropdownView:(UIView *)parentView withMessage:(NSString *)message
{
    
	UILabel *dropdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	
	if(message == nil) {
		dropdownLabel.text = @"No Internet Connection";
	}
	else {
		dropdownLabel.text = message;
	}
	
	dropdownLabel.font = [RepunchUtils repunchFontWithSize:17 isBold:YES];
	dropdownLabel.textAlignment = NSTextAlignmentCenter;
	dropdownLabel.textColor = [UIColor whiteColor];
	dropdownLabel.backgroundColor = [UIColor colorWithRed:(0.9) green:(0.0) blue:(0.0) alpha:1.0]; //[UIColor redColor];
	[parentView addSubview:dropdownLabel];
	
	CGRect rect = dropdownLabel.frame;
    rect.origin.y = -40;
	dropdownLabel.frame = rect;

	// Fade out the view right away
    [UIView animateWithDuration:0.25
						  delay: 0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect2 = dropdownLabel.frame;
						 rect2.origin.y = 0;
						 dropdownLabel.frame = rect2;
					 }
					 completion:^(BOOL finished) {
						 // Wait one second and then fade in the view
						 [UIView animateWithDuration:0.25
											   delay: 1.0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  CGRect rect3 = dropdownLabel.frame;
											  rect3.origin.y = -40;
											  dropdownLabel.frame = rect3;
										  }
										  completion:^(BOOL finished) {
											  [dropdownLabel removeFromSuperview];
										  }];
					 }];
}

+ (void)configureAppearance
{
    [UITabBar appearance].barStyle = UIBarStyleDefault;
	[UITabBar appearance].backgroundColor = [UIColor whiteColor];
    [UITabBar appearance].tintColor = [self repunchOrangeColor];

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [RepunchUtils repunchFontWithSize:12 isBold:YES]}
                                                forState:UIControlStateNormal];
	
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
														   NSFontAttributeName: [RepunchUtils repunchFontWithSize:15 isBold:NO]}
												forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
														   NSFontAttributeName: [RepunchUtils repunchFontWithSize:17 isBold:YES]}];
	
	[[UIActivityIndicatorView appearance] setTintColor:[self repunchOrangeColor]];
	
	//[[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"nav_back"]];
	//[[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"nav_back"]];
}

+ (void)setupNavigationController:(UINavigationController *)navController
{
	navController.navigationBar.tintColor = [UIColor whiteColor];
	[navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"orange_gradient"] forBarMetrics:UIBarMetricsDefault];
	//navController.navigationBar.barTintColor = [RepunchUtils repunchOrangeColor];
	navController.navigationBar.barStyle = UIBarStyleBlack;
	navController.navigationBar.translucent = YES;
}

+ (CAGradientLayer *)blackGradient
{
	
    UIColor *darkBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    UIColor *lightBlack = [UIColor colorWithRed:0.0  green:0.0 blue:0.0 alpha:0.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)lightBlack.CGColor, darkBlack.CGColor, nil];
	
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
	//gradientLayer.locations = @[@0.00f, @0.55f, @1.00f];
	
    return gradientLayer;
}

+ (UIColor *)repunchOrangeColor // RGBA = F79234FF
{
	return [UIColor colorWithRed:(247/255.0) green:(146/255.0) blue:(52/255.0) alpha:1.0];
}

+ (UIColor *)lightRepunchOrangeColor
{
	return [UIColor colorWithRed:(246/255.0) green:(146/255.0) blue:(29/255.0) alpha:1.0];
}

+ (UIColor *)repunchOrangeHighlightedColor
{
	return [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:0.5];
}

+ (UIFont *)repunchFontWithSize:(NSUInteger)fontSize isBold:(BOOL)isBold
{
	if(isBold) {
		return [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
	}
	else {
		return [UIFont fontWithName:@"Avenir-Medium" size:fontSize];
	}
}

+ (void)clearNotificationCenter
{
	//setting badge number to 0 resets notifications
	NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	[UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
	[[UIApplication sharedApplication] cancelAllLocalNotifications];	// make sure no pending local notifications
}

+ (UIImage *)imageScaledForThumbnail:(UIImage *)image
{
	CGFloat imageWidth = 128;
	CGFloat imageHeight = 128;
	
	CGRect imageFrame = CGRectMake(0, 0, imageWidth, imageHeight);
	
	CALayer *imageLayer = [CALayer layer];
	imageLayer.frame = imageFrame;
	imageLayer.contents = (id) image.CGImage;
	
	imageLayer.cornerRadius = 16;
	imageLayer.masksToBounds = YES;
	
	UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
	
	[imageLayer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
    return newImage;
}


+ (CGRect)frameForViewWithInitialFrame:(CGRect)viewInitialFrame withDynamicLabels:(NSArray*)labels andInitialHights:(NSArray*)initialHeights
{
    CGFloat totalDelta = 0;

    
    for (NSUInteger i = 0  ; i < labels.count; i++) {

        UILabel *label = labels[i];
        CGFloat initialHeight = [initialHeights[i] floatValue];

        CGSize max = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);

        CGFloat expectedHeight = [label.text sizeWithFont:label.font
                                        constrainedToSize:max
                                            lineBreakMode:label.lineBreakMode].height;

        CGFloat delta = expectedHeight - initialHeight;

        if (delta < 1) {
            delta = 0;
        }

        if (label.text.length < 1) {
            delta -= label.font.pointSize * 1.4f;
        }

        totalDelta += delta;
    }

    viewInitialFrame.size.height +=  totalDelta;
    
    return viewInitialFrame;
}

@end
