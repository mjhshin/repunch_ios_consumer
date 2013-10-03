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

+ (void)showDefaultErrorMessage;
+ (void)setupNavigationController:(UINavigationController *)navController;
+ (UIColor *)repunchOrangeColor;
+ (void)clearNotificationCenter;

@end
