//
//  AppDelegate.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
	DataManager* sharedData;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Set up API keys
    [Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
                  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
    
    [PFFacebookUtils initializeFacebook];    
    [Crittercism enableWithAppID: @"51df08478b2e331138000003"];
	
	[application registerForRemoteNotificationTypes:
	 UIRemoteNotificationTypeBadge |
	 UIRemoteNotificationTypeAlert |
	 UIRemoteNotificationTypeSound];
	
	//For push when app not loaded in memory
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif)
	{
        //TODO? If app always refreshes after didFinishLaunchingWithOptions, no need.
    }
	
	sharedData = [DataManager getSharedInstance];
	[self checkLoginState];
	
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

#pragma mark - Push Notification methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
	didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{	
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator. Ignore this
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	//setting badge number to 0 resets notifications
	NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	[UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
	[[UIApplication sharedApplication] cancelAllLocalNotifications];	// make sure no pending local notifications
	
	NSString *pushType = [userInfo objectForKey:@"type"];
	
	if( [pushType isEqualToString:@"punch"] )
	{
		NSLog(@"Push received: punch");
		[PunchHandler handlePush:userInfo];
	}
	else if( [pushType isEqualToString:@"redeem"] )
	{
		NSLog(@"Push received: redeem");
		[RedeemHandler handlePush:userInfo];
	}
	else if( [pushType isEqualToString:@"redeem_offer_gift"] )
	{
		NSLog(@"Push received: redeem offer/gift");
		[RedeemHandler handleOfferGiftPush:userInfo];
	}
    else if( [pushType isEqualToString:@"message"] )
	{
		NSLog(@"Push received: message");
        [MessageHandler handlePush:userInfo];
	}
    else if( [pushType isEqualToString:@"gift"] )
	{
		NSLog(@"Push received: gift");
		[MessageHandler handleGiftPush:userInfo forReply:NO];
	}
    else if( [pushType isEqualToString:@"gift_reply"] )
	{
		NSLog(@"Push received: gift_reply");
		[MessageHandler handleGiftPush:userInfo forReply:YES];
	}
}

- (void)checkLoginState
{
	PFUser* currentUser = [PFUser currentUser];
	
    if (currentUser)
	{
		//NSLog(@"PFUser is non-null");
		[Crittercism setUsername:currentUser.username];
		
		//if patron object is null for some reason
        if ( ![sharedData patron] )
		{
			Reachability *reachability = [Reachability reachabilityForInternetConnection];
			NetworkStatus internetStatus = [reachability currentReachabilityStatus];
			
			if (internetStatus != NotReachable)
			{
				PFObject *patron = [currentUser objectForKey:@"Patron"];
				[patron fetchIfNeededInBackgroundWithBlock:^(PFObject *result, NSError *error)
				 {
					 if (!error) {
						 [sharedData setPatron:result];
						 [self presentTabBarController];
					 }
					 else {
						 [RepunchUtils showDefaultErrorMessage];
						 [PFUser logOut];
						 [self checkLoginState];
						 NSLog(@"Failed to fetch Patron object: %@", error);
					 }
				 }];
			}
			else
			{
				[RepunchUtils showDefaultErrorMessage];
				[PFUser logOut];
				[self checkLoginState];
			}
        }
		else
		{
            [self presentTabBarController];
		}
		
    }
	else
	{
		[self presentLandingViews];
    }
}

- (void)presentTabBarController
{
    MyPlacesViewController *myPlacesVC = [[MyPlacesViewController alloc] init];
    InboxViewController *inboxVC = [[InboxViewController alloc] init];
	
	UINavigationController *myPlacesNavController = [[UINavigationController alloc] initWithRootViewController:myPlacesVC];
	UINavigationController *inboxNavController = [[UINavigationController alloc] initWithRootViewController:inboxVC];
	[RepunchUtils setupNavigationController:myPlacesNavController];
	[RepunchUtils setupNavigationController:inboxNavController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = @[myPlacesNavController, inboxNavController];
	tabBarController.tabBar.tintColor = [RepunchUtils repunchOrangeColor];
	tabBarController.tabBar.barStyle = UIBarStyleBlack;
	
    UITabBarItem *myPlacesTab = [tabBarController.tabBar.items objectAtIndex:0];
    [myPlacesTab setTitle:@"My Places"];
    [myPlacesTab setImage:[UIImage imageNamed:@"ico-tab-places.png"]];
    
	UITabBarItem *inboxTab = [tabBarController.tabBar.items objectAtIndex:1];
    [inboxTab setTitle:@"Inbox"];
    [inboxTab setImage:[UIImage imageNamed:@"ico-tab-inbox.png"]];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [attributes setValue:[UIFont fontWithName:@"Avenir-Heavy" size:12] forKey:NSFontAttributeName];
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
	
	self.window.rootViewController = tabBarController;
	[self.window makeKeyAndVisible];
	
	[inboxVC view]; //pre-load second tab
	[FBFriendPickerViewController class]; //pre-load Facebook friend picker
}

- (void)presentLandingViews
{
	LandingViewController *landingVC = [[LandingViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:landingVC];
	[RepunchUtils setupNavigationController:navController];
	self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
}

- (void)logout
{
	[sharedData clearData];
    [PFUser logOut];
	//TODO: unload tab bar controller so it isn't see through when you go to register/login
	[self presentLandingViews];
}

@end
