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
@property (assign, nonatomic) BOOL isVisible;

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
    if (self.isVisible ) {
        [RPAlertController centerView:self];
    }
    else{
        [RPAlertController hideAlert:self isDown:YES];
    }
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
        [self hideAlert:alert isDown:YES];
    }

    if (alertStack.count > 1 || alert.isVisible) {
        return;
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


    alertWindow.rootViewController = alert;
    alert.view.frame = alert.initialFrame;
    [self hideAlert:alert isDown:YES];

    [UIAlertView animateWithDuration:ANIMATION_DURATION animations:^{
        [self centerView:alert];
    }];
}


+ (void)popAlert
{
    RPAlertController *toRemove = [alertStack firstObject];

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self hideAlert:toRemove isDown:NO];

    } completion:^(BOOL finished) {

        [alertStack removeObject:toRemove];

        RPAlertController *toDisplay = [alertStack firstObject];
        alertWindow.rootViewController = toDisplay;
        toDisplay.view.frame = toDisplay.initialFrame;
        [self hideAlert:toDisplay isDown:YES];

        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [self centerView:toDisplay];
        } completion:^(BOOL finished) {
            if (!toDisplay) {
                [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                alertWindow = nil;
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
    controller.isVisible = YES;

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
    alert.isVisible = NO;
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
