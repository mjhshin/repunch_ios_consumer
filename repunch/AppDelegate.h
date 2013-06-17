//
//  AppDelegate.h
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LandingViewController.h"
#import "PlacesViewController.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) LandingViewController *loginVC;
@property (nonatomic, retain) PlacesViewController *placesVC;

@property (nonatomic, retain) FBSession *session;
@property (nonatomic, retain) NSDictionary<FBGraphUser> *fbUser;
@property (nonatomic, retain) User *localUser;

-(void)makeTabBarHidden:(BOOL)hide;

@end
