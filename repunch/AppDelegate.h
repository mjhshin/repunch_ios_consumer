//
//  AppDelegate.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"
#import "InboxViewController.h"
#import "LandingViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Crittercism.h"
#import "SIAlertView.h"
#import "DataManager.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PunchHandler.h"
#import "RedeemHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *navController;

- (void)presentLandingViews;
- (void)presentTabBarController;
- (void)logout;

@end
