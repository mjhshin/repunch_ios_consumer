//
//  RepunchUtils.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepunchUtils : NSObject

+ (BOOL)isConnectionAvailable;

+ (void)showDialogWithTitle:(NSString *)title withMessage:(NSString *)message;
+ (void)showConnectionErrorDialog;

+ (void)showCustomDropdownView:(UIView *)parentView withMessage:(NSString *)message;
+ (void)showDefaultDropdownView:(UIView *)parentView;
+ (void)showPunchCode:(NSString *)punchCode;

+ (void)setupNavigationController:(UINavigationController *)navController;

+ (UIColor *)repunchOrangeColor;
+ (UIColor *)repunchOrangeColorWithAlpha:(CGFloat)alpha;
+ (UIColor *)lightRepunchOrangeColor;
+ (UIColor *)darkRepunchOrangeColor;
+ (UIColor *)repunchOrangeHighlightedColor;

+ (UIFont *)repunchFontWithSize:(NSUInteger)fontSize isBold:(BOOL)isBold;

+ (CAGradientLayer *)blackGradient;

+ (void)clearNotificationCenter;
+ (void)configureAppearance;

+ (UIImage *)imageScaledForThumbnail:(UIImage *)image;
+ (UIImageView *)blurredImageFromView:(UIView *)view;

+ (void)callPhoneNumber:(NSString *)phoneNumber;

+ (NSString *)formattedDistance:(double)distance;

@end
