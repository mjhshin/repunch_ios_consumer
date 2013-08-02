//
//  AppDelegate.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NSMutableDictionary *patronStores;
@property (strong, nonatomic) NSMutableDictionary *stores;
@property (strong, nonatomic) NSMutableDictionary *messages;
@property (strong, nonatomic) NSMutableDictionary *messageStatuses;

-(void)presentTabBarController;
-(void)logout;

@end
