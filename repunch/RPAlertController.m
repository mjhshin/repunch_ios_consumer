//
//  RPAlertController.m
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPAlertController.h"

#define ANIMATION_DURATION 0.3

//static const UIWindowLevel UIWindowLevelORAlert = 1999.0;  // don't overlap system's alert
//static const UIWindowLevel UIWindowLevelORAlertBackground = 1998.0; // below the alert window

static UIWindow *alertWindow;
static NSMutableArray *alertStack;
static NSMutableArray *actionStack;

@interface RPAlertController ()
@property (assign, nonatomic) CGRect keyboardFrame;
@property (assign, nonatomic) BOOL isAction;
@end

@implementation RPAlertController

- (void)viewDidLoad
{
    self.keyboardFrame = CGRectZero;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(didHidekeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

/*
- (void)dealloc
{
    NSLog(@"Dealloc Alert");
}
*/

- (void)didShowKeyboard:(NSNotification*)notification
{
    NSValue* value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    self.keyboardFrame = value.CGRectValue;

    [UIAlertView animateWithDuration:ANIMATION_DURATION animations:^{
        [RPAlertController centerView:self];
    }];
}

- (void)didHidekeyboard:(NSNotification*)notification
{
    self.keyboardFrame = CGRectZero;

    [UIAlertView animateWithDuration:ANIMATION_DURATION animations:^{
        [RPAlertController centerView:self];
    }];
}

- (void)showAlert
{
    self.isAction = NO;
    [RPAlertController pushAlert:self];
}

- (void)hideAlert
{
    [RPAlertController popAlert:self];
}

- (void)showAsAction
{
    self.isAction = YES;
    [RPAlertController pushAlert:self];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [RPAlertController centerView:self];
}

+ (void)pushAlert:(RPAlertController*)alert
{
    if (![alertStack containsObject:alert] && !alert.isAction) {

        if (!alertStack) {
            alertStack = [NSMutableArray array];
        }

        [RPAlertController addShadowToAlert:alert];
        [alertStack addObject:alert];
    }
    else if (![actionStack containsObject:alert] && alert.isAction) {

        if (!actionStack) {
            actionStack = [NSMutableArray array];
        }

        [RPAlertController addShadowToAlert:alert];
        [actionStack addObject:alert];
    }

    if (!alertWindow) {
        alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        alertWindow.opaque = NO;
        alertWindow.windowLevel = UIWindowLevelNormal;
        [alertWindow setAutoresizesSubviews:NO];

        UIViewController * rootController = [[UIViewController alloc] init];
        UIView *dim = [[UIView alloc] initWithFrame:alertWindow.frame];

        dim.backgroundColor = [UIColor blackColor];
        dim.alpha = 0.3;
        dim.autoresizingMask = alertWindow.autoresizingMask;
        [rootController.view addSubview:dim];

        alertWindow.rootViewController = rootController;
    }

    [alertWindow makeKeyAndVisible];

    if ((alertStack.count > 1 && !alert.isAction) || (actionStack.count > 1 && alert.isAction)) {
        return;
    }

    RPAlertController *action = [actionStack firstObject];

    [UIView animateWithDuration:ANIMATION_DURATION
					 animations:^{
						 if (!alert.isAction) {
							 [RPAlertController hideAlert:action isDown:YES];
						 }
					 }
					 completion:^(BOOL finished) {
						 [action removeFromParentViewController];
						 [action.view removeFromSuperview];
						 
						 [alertWindow.rootViewController addChildViewController:alert];
						 [alertWindow.rootViewController.view addSubview:alert.view];
						 
						 [RPAlertController hideAlert:alert isDown:YES];
						 
						 [UIAlertView animateWithDuration:ANIMATION_DURATION
											   animations:^{
												   [RPAlertController centerView:alert];
											   }];
					 }];
}

+ (void)popAlert:(RPAlertController*)toPop
{
    if (toPop.isAction) {
        [actionStack removeObject:toPop];
    }
    else {
        [alertStack removeObject:toPop];
    }


    RPAlertController *toDisplay = (alertStack.count > 0) ? [alertStack firstObject] : [actionStack firstObject];

    if (toDisplay) {
        [alertWindow.rootViewController addChildViewController: toDisplay];
        [alertWindow.rootViewController.view addSubview:toDisplay.view];
        [RPAlertController hideAlert:toDisplay isDown:YES];
    }

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{

        [RPAlertController hideAlert:toPop isDown:toPop.isAction];
		
        if (!toPop.isAction) {
            // animate when displaying an alert, otherwise complete animation then animate
            [RPAlertController centerView:toDisplay];
        }
	} completion:^(BOOL finished) {

        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            if (toPop.isAction) {
                [RPAlertController centerView:toDisplay];
            }

        } completion:^(BOOL finished) {
			[toPop removeFromParentViewController];
            [toPop.view removeFromSuperview];
            [toPop.view endEditing:YES];


            // Remove ShadowView
            toPop.view = [[toPop.view subviews] firstObject];

            if (alertStack.count < 1 && actionStack.count < 1) {
                [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                [alertWindow resignKeyWindow];
                [alertWindow removeFromSuperview];
                alertWindow.rootViewController = nil;
                alertWindow = nil;
                actionStack = nil;
            }
        }];
    }];
}

+ (void)centerView:(RPAlertController*)alert
{
    CGRect alertFrame = alert.view.frame;
    CGRect windowFrame = alertWindow.frame;

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat temp = windowFrame.size.height;
        windowFrame.size.height = windowFrame.size.width;
        windowFrame.size.width = temp;
    }

    alertFrame.origin.x = (CGRectGetWidth(windowFrame) - CGRectGetWidth(alertFrame))/2 ;

    if (alert.isAction) {
        alertFrame.origin.y = CGRectGetHeight(windowFrame) - CGRectGetHeight(alertFrame);
    }
    else {
        alertFrame.origin.y = (CGRectGetHeight(windowFrame) - CGRectGetHeight(alertFrame))/2 ;
    }

    CGFloat keyboardHeight = CGRectGetHeight(alert.keyboardFrame);
    alertFrame.origin.y -= keyboardHeight /2;

    if (alertFrame.origin.y < 22) {
        alertFrame.origin.y = 22;
    }

    CGFloat maxSize =  windowFrame.size.height - keyboardHeight - 44;

    if (alertFrame.size.height > maxSize) {
        alertFrame.size.height  = maxSize;
    }

    alert.view.frame = alertFrame;
}

+ (void)hideAlert:(RPAlertController*)alert isDown:(BOOL)isDown
{
    CGRect alertFrame = alert.view.frame;
    CGRect windowFrame = alertWindow.frame;

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];

    if (UIInterfaceOrientationIsLandscape(orientation)){
        CGFloat temp = windowFrame.size.height;
        windowFrame.size.height = windowFrame.size.width;
        windowFrame.size.width = temp;
    }

    alertFrame.origin.x = (CGRectGetWidth(windowFrame) - CGRectGetWidth(alertFrame))/2;

    if (isDown) {
        alertFrame.origin.y = CGRectGetHeight(windowFrame);
    }
    else {
        alertFrame.origin.y = - CGRectGetHeight(alertFrame);
    }
    alert.view.frame = alertFrame;
}

+ (void) addShadowToAlert:(RPAlertController*)alert
{
    if (!alert.isAction) {
        alert.view.layer.cornerRadius = 10;
        alert.view.layer.masksToBounds = YES;
    }

    UIView *shadowView = [[UIView alloc] initWithFrame:alert.view.frame];
    shadowView.layer.shadowOffset = CGSizeZero;
    shadowView.layer.shadowRadius = 5;
    shadowView.layer.cornerRadius = 10;
    shadowView.layer.shadowOpacity = 0.4;
    
    [shadowView addSubview:alert.view];
    
    alert.view = shadowView;
}

@end
