//
//  AppDelegate.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

//eeyeargh. using the app delegate for global variables is making me nervousss.
@property (strong, nonatomic) PFObject *patronObject;
@property (strong, nonatomic) User *localUser;

-(void)makeTabBarHidden:(BOOL)hide;
-(void)logout;
-(void)login;



@end
