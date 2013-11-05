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

@implementation RepunchUtils

+ (BOOL)isConnectionAvailable
{
	Reachability *reach = [Reachability reachabilityForInternetConnection];
	NetworkStatus status = [reach currentReachabilityStatus];
	return (status != NotReachable);
}

+ (void)showDialogWithTitle:(NSString *)title withMessage:(NSString *)message
{
	SIAlertView *errorDialog = [[SIAlertView alloc] initWithTitle:title
													   andMessage:message];
	[errorDialog addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[errorDialog show];
}

+ (void)showConnectionErrorDialog
{
	SIAlertView *errorDialog = [[SIAlertView alloc] initWithTitle:@"Error"
													   andMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
	[errorDialog addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[errorDialog show];
}

+ (void)showCustomDropdownView:(UIView *)parentView withMessage:(NSString *)message
{
	[self showNavigationBarDropdownView:parentView withMessage:message];
}

+ (void)showDefaultDropdownView:(UIView *)parentView
{
	[self showNavigationBarDropdownView:parentView withMessage:nil];
}

+ (void)showPunchCode:(UIView *)parentView withPunchCode:(NSString *)punchCode
{
	UILabel *dropdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	NSString *message = [NSString stringWithFormat:@"Your Punch Code is %@", punchCode];
	dropdownLabel.text = message;
	dropdownLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:17.0];
	dropdownLabel.textAlignment = NSTextAlignmentCenter;
	dropdownLabel.textColor = [UIColor whiteColor];
	dropdownLabel.backgroundColor = [RepunchUtils repunchOrangeColor];
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
											   delay: 2.5
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

+ (void)showNavigationBarDropdownView:(UIView *)parentView withMessage:(NSString *)message
{
	UILabel *dropdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	
	if(message == nil) {
		dropdownLabel.text = @"No Internet Connection";
	}
	else {
		dropdownLabel.text = message;
	}
	
	dropdownLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:17.0];
	dropdownLabel.textAlignment = NSTextAlignmentCenter;
	dropdownLabel.textColor = [UIColor whiteColor];
	dropdownLabel.backgroundColor = [UIColor redColor];
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

+ (void)setDefaultButtonStyle:(UIButton *)button
{
	[button setBackgroundImage:[UIImage imageNamed:@"orange_button.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"orange_button_highlighted.png"] forState:UIControlStateHighlighted];
	[button.layer setCornerRadius:5];
	[button setClipsToBounds:YES];
}

+ (void)setDisabledButtonStyle:(UIButton *)button
{
	[button setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateHighlighted];
	[button.layer setCornerRadius:5];
	[button setClipsToBounds:YES];
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
