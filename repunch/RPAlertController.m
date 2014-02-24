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
@property (assign, nonatomic) CGPoint lastCenter;

@end

@implementation RPAlertController


- (void)showAlert
{
    [RPAlertController pushAlert:self];
}

- (void)hideAlert
{
    [RPAlertController popAlert];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [RPAlertController centerView:self];
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}



+ (void)pushAlert:(RPAlertController*)alert
{

    if (![alertStack containsObject:alert]) {

        if (!alertStack) {
            alertStack = [NSMutableArray array];
        }

        alert.initialFrame = alert.view.frame;
        alert.view.layer.cornerRadius = 10;
        alert.view.layer.masksToBounds = YES;

        // make a shadow view since mask to bounds will clip the shadow

        UIView *shadowView = [[UIView alloc] initWithFrame:alert.view.frame];
        shadowView.layer.shadowOffset = CGSizeZero;
        shadowView.layer.shadowRadius = 5;
        shadowView.layer.cornerRadius = 10;

        shadowView.layer.shadowOpacity = 0.4;

        [shadowView addSubview:alert.view];
        alert.view = shadowView;

        [alertStack addObject:alert];
        [RPAlertController hideAlert:alert isDown:YES];
    }


    if (!alertWindow) {
        alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        alertWindow.opaque = NO;
        alertWindow.windowLevel = UIWindowLevelNormal;
        [alertWindow setAutoresizesSubviews:NO];

        UIView *dim = [[UIView alloc] initWithFrame:alertWindow.frame];
        dim.backgroundColor = [UIColor blackColor];
        dim.alpha = 0.3;
        [alertWindow addSubview:dim];
    }

    [alertWindow makeKeyAndVisible];

    if (alertStack.count > 1) {
        return;
    }


    alertWindow.rootViewController = alert;
    alert.view.frame = alert.initialFrame;
    [RPAlertController hideAlert:alert isDown:YES];

    [UIAlertView animateWithDuration:ANIMATION_DURATION animations:^{
        [RPAlertController centerView:alert];
    }];
}


+ (void)popAlert
{

    __block RPAlertController *toRemove = [alertStack firstObject];

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [RPAlertController hideAlert:toRemove isDown:NO];

    } completion:^(BOOL finished) {

        [alertStack removeObject:toRemove];
        toRemove = nil;

        RPAlertController *toDisplay = [alertStack firstObject];
        alertWindow.rootViewController = toDisplay;
        toDisplay.view.frame = toDisplay.initialFrame;
        [RPAlertController hideAlert:toDisplay isDown:YES];

        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [RPAlertController centerView:toDisplay];
        } completion:^(BOOL finished) {
            if (!toDisplay) {
                [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                [alertWindow resignKeyWindow];
                [alertWindow removeFromSuperview];
                alertWindow = nil;
                alertStack = nil;
            }
        }];
        
    }];
}

+ (void)centerView:(RPAlertController*)controller
{
    CGRect frame = [controller initialFrame];

    frame.size = [self fixSize:frame.size];

    frame.origin.x = (CGRectGetWidth(alertWindow.frame) - CGRectGetWidth(frame)) /2;
    frame.origin.y = (CGRectGetHeight(alertWindow.frame)- CGRectGetHeight(frame))/2;

    frame = CGRectIntegral(frame);

    controller.view.frame = frame;

}


+(void)hideAlert:(RPAlertController*)alert isDown:(BOOL)isDown
{
    CGRect frame = [alert initialFrame];
    frame.size = [self fixSize:frame.size];

    NSInteger ss = isDown ? 1 : -1;

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)){
        // Fix Velocity
        NSInteger s = orientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1;

        CGRect rect1  =  orientation == UIInterfaceOrientationLandscapeLeft ? alertWindow.frame : frame;
        CGRect rect2  =  orientation != UIInterfaceOrientationLandscapeLeft ? alertWindow.frame : frame;
        CGRect rect3 = isDown ? rect1 : rect2;

        frame.origin.x = ss*s* CGRectGetWidth(rect3) ;
        frame.origin.y = (CGRectGetHeight(alertWindow.frame)- CGRectGetHeight(frame)) /2 ;
    }
    else {
        NSInteger s = orientation == UIInterfaceOrientationPortrait ? 1 : -1;
        CGRect rect1  = orientation == UIInterfaceOrientationPortrait ? alertWindow.frame : frame;
        CGRect rect2  = orientation != UIInterfaceOrientationPortrait ? alertWindow.frame : frame;
        CGRect rect3 = isDown ? rect1 : rect2;

        frame.origin.x = (CGRectGetWidth(alertWindow.frame) - CGRectGetWidth(frame)) /2;
        frame.origin.y = ss*s*(CGRectGetHeight(rect3));
    }

    frame = CGRectIntegral(frame);

    alert.view.frame = frame;
}


+ (CGSize)fixSize:(CGSize)size
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)){
        CGFloat t = size.width;
        size.width = size.height;
        size.height = t;
    }

    return size;
}


@end
