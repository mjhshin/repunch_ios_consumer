//
//  RepunchUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

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

+ (void)showConnectionErrorDialog
{
	[RPCustomAlertController showDefaultAlertWithTitle:@"No Internet Connection"
											andMessage:@"Please check your connection and try again."];
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
    [RPCustomAlertController showDefaultAlertWithTitle:title andMessage:message];
}

+ (void)showPunchCode:(NSString *)punchCode
{
    [RPCustomAlertController showPunchCodeAlertWithCode:punchCode];
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
    rect.origin.y = 0;
	dropdownLabel.frame = rect;

	// Fade out the view right away
    [UIView animateWithDuration:0.25
						  delay: 0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect2 = dropdownLabel.frame;
						 rect2.origin.y = 64;
						 dropdownLabel.frame = rect2;
					 }
					 completion:^(BOOL finished) {
						 // Wait one second and then fade in the view
						 [UIView animateWithDuration:0.25
											   delay: 1.0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  CGRect rect3 = dropdownLabel.frame;
											  rect3.origin.y = 0;
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
	
    UIColor *lightBlack = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    UIColor *darkBlack = [UIColor colorWithRed:0.0  green:0.0 blue:0.0 alpha:0.0];
	
    NSArray *colors = [NSArray arrayWithObjects:(id)darkBlack.CGColor, lightBlack.CGColor, nil];
	
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

+ (UIColor *)darkRepunchOrangeColor
{
	return [UIColor colorWithRed:(220/255.0) green:(120/255.0) blue:(20/255.0) alpha:1.0];
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

+ (void)callPhoneNumber:(NSString *)phoneNumber
{
	NSCharacterSet* numericSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *number = [[phoneNumber componentsSeparatedByCharactersInSet:numericSet] componentsJoinedByString:@""];
    
	NSString *urlString = [@"tel://" stringByAppendingString:number];
	NSURL *url = [NSURL URLWithString:urlString];
	
	if( [[UIApplication sharedApplication] canOpenURL:url] ) {
		[[UIApplication sharedApplication] openURL:url];
	}
	else {
		[RepunchUtils showDialogWithTitle:@"This device does not support phone calls" withMessage:nil];
	}
}

+ (NSString *)formattedDistance:(double)distance
{
	if(distance < 0.1) {
		return [NSString stringWithFormat:@"%.0f ft", distance*5280];
	}
	else {
		return [NSString stringWithFormat:@"%.1f mi", distance];
	}
}

@end
