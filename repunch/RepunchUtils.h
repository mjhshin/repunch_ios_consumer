//
//  RepunchUtils.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIAlertView.h"

@interface RepunchUtils : NSObject

+ (void)showDialogWithTitle:(NSString *)title withMessage:(NSString *)message;
+ (void)showConnectionErrorDialog;
+ (void)setupNavigationController:(UINavigationController *)navController;
+ (UIColor *)repunchOrangeColor;
+ (void)clearNotificationCenter;
+ (void)configureAppearance;

@end
