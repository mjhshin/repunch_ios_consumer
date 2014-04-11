//
//  AppDelegate.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LandingViewController.h"
#import "RPTabBarController.h"
#import "RPNavigationController.h"
#import "PunchHandler.h"
#import "RedeemHandler.h"
#import "MessageHandler.h"
#import "Reachability.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)presentLandingViews;
- (void)presentTabBarController;
- (void)logout;

@end