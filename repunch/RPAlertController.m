//
//  RPAlertController.m
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPAlertController.h"

#define ANIMATION_DURATION 0.3

static const UIWindowLevel UIWindowLevelORAlert = 1999.0;  // don't overlap system's alert
static const UIWindowLevel UIWindowLevelORAlertBackground = 1998.0; // below the alert window

static UIWindow *alertWindow;
static NSMutableArray *alertStack;

@interface RPAlertController ()
@property (assign, nonatomic) CGRect keyboardFrame;
@end

@implementation RPAlertController


- (void)viewDidLoad
{
    self.keyboardFrame = CGRectZero;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(didHidekeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

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
    [RPAlertController pushAlert:self];
}

- (void)hideAlert
{
    [RPAlertController popAlert];
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

    if (![alertStack containsObject:alert]) {

        if (!alertStack) {
            alertStack = [NSMutableArray array];
        }

        alert.view.layer.cornerRadius = 10;
        alert.view.layer.masksToBounds = YES;

        UIView *shadowView = [[UIView alloc] initWithFrame:alert.view.frame];
        shadowView.layer.shadowOffset = CGSizeZero;
        shadowView.layer.shadowRadius = 5;
        shadowView.layer.cornerRadius = 10;

        shadowView.layer.shadowOpacity = 0.4;

        [shadowView addSubview:alert.view];

        alert.view = shadowView;

        [alertStack addObject:alert];
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

    if (alertStack.count > 1) {
        return;
    }


    [alertWindow.rootViewController addChildViewController:alert];
    [alertWindow.rootViewController.view addSubview:alert.view];

    [RPAlertController hideAlert:alert isDown:YES];

    [UIAlertView animateWithDuration:ANIMATION_DURATION animations:^{
        [RPAlertController centerView:alert];
    }];
}



+ (void)popAlert
{

    RPAlertController *toRemove = [alertStack firstObject];
    [alertStack removeObject:toRemove];

    RPAlertController *toDisplay = [alertStack firstObject];

    if (toDisplay) {

        [alertWindow.rootViewController addChildViewController: toDisplay];
        [alertWindow.rootViewController.view addSubview:toDisplay.view];
        [RPAlertController hideAlert:toDisplay isDown:YES];
    }

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{

        [RPAlertController hideAlert:toRemove isDown:NO];
        [RPAlertController centerView:toDisplay];

    } completion:^(BOOL finished) {

        [toRemove removeFromParentViewController];
        [toRemove.view removeFromSuperview];
        // Remove ShadowView
        toRemove.view = [[toRemove.view subviews] firstObject];

        if (!toDisplay){

            [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
            [alertWindow resignKeyWindow];
            [alertWindow removeFromSuperview];
            alertWindow.rootViewController = nil;
            alertWindow = nil;
            alertStack = nil;
        }
    }];
}



+ (void)centerView:(RPAlertController*)alert
{
    CGRect alertFrame = alert.view.frame;
    CGRect windowFrame = alertWindow.frame;

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)){
        CGFloat temp = windowFrame.size.height;
        windowFrame.size.height = windowFrame.size.width;
        windowFrame.size.width = temp;
    }

    alertFrame.origin.x = (CGRectGetWidth(windowFrame) - CGRectGetWidth(alertFrame))/2 ;
    alertFrame.origin.y = (CGRectGetHeight(windowFrame) - CGRectGetHeight(alertFrame))/2 ;
    alertFrame.origin.y -= CGRectGetHeight(alert.keyboardFrame) /2;
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


@end
