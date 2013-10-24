//
//  RepunchUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RepunchUtils.h"

@implementation RepunchUtils

+ (void)showDefaultErrorMessage
{
	SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error"
														 andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
	[errorDialogue addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[errorDialogue show];
}

+ (void)configureAppearance
{
    [UITabBar appearance].barStyle = UIBarStyleDefault;
	[UITabBar appearance].backgroundColor = [UIColor whiteColor];
    [UITabBar appearance].tintColor = [self repunchOrangeColor];

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:12]}
                                                forState:UIControlStateNormal];
	
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
														   NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:15]}
												forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
														   NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:17]}];
}

+ (void)setupNavigationController:(UINavigationController *)navController
{
	navController.navigationBar.tintColor = [UIColor whiteColor];
	navController.navigationBar.barTintColor = [RepunchUtils repunchOrangeColor];
	navController.navigationBar.translucent = NO;
}

+ (UIColor *)repunchOrangeColor // RGBA = F79234FF
{
	return [UIColor colorWithRed:(247/255.0) green:(146/255.0) blue:(52/255.0) alpha:1.0];
}

+ (void)clearNotificationCenter
{
	//setting badge number to 0 resets notifications
	NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	[UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
	[[UIApplication sharedApplication] cancelAllLocalNotifications];	// make sure no pending local notifications
}

@end
