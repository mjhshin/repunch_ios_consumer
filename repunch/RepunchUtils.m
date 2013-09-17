//
//  RepunchUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RepunchUtils.h"

@implementation RepunchUtils

+ (void) showDefaultErrorMessage
{
	SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error"
														 andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
	[errorDialogue addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[errorDialogue show];
}

+ (void)setupNavigationController:(UINavigationController *)navController
{
	//if( [self isiOSSeven] ) {
		navController.navigationBar.tintColor = [UIColor whiteColor];
		navController.navigationBar.barTintColor = [RepunchUtils repunchOrangeColor];
		navController.navigationBar.translucent = NO;
		
		[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
															   NSFontAttributeName: [UIFont fontWithName:@"Avenir"
																									size:15]}
													forState:UIControlStateNormal];
		
		[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor],
																NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy"
																									 size:17]}];
	//}
	//else {
	//	navController.navigationBar.tintColor = [RepunchUtils repunchOrangeColor];
		
	//	[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor],
	//														   UITextAttributeFont: [UIFont fontWithName:@"Avenir"
	//																								size:15]}
	//												forState:UIControlStateNormal];
		
	//	[[UINavigationBar appearance] setTitleTextAttributes: @{UITextAttributeTextColor: [UIColor whiteColor],
	//															UITextAttributeFont: [UIFont fontWithName:@"Avenir-Heavy"
	//																								 size:17]}];
	//}
}

+ (UIColor *)repunchOrangeColor // RGBA = F79234FF
{
	return [UIColor colorWithRed:(247/255.0) green:(146/255.0) blue:(52/255.0) alpha:1.0];
}

/*
+ (BOOL)isiOSSeven //returns YES for iOS 7.0+
{
	return [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending;
}
*/
@end
