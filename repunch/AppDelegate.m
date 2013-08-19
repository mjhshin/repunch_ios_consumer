//
//  AppDelegate.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    LandingViewController *landingVC;
    MyPlacesViewController *myPlacesVC;
    InboxViewController *inboxVC;
	DataManager* sharedData;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
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
    //[PFPush handlePush:userInfo];

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
	}
    else if( [pushType isEqualToString:@"gift_reply"] )
	{
		NSLog(@"Push received: gift_reply");
	}
}

- (void)checkLoginState
{
	PFUser* currentUser = [PFUser currentUser];
	
    if (currentUser)
	{
		//if patron object is null for some reason
        if ( ![sharedData patron] )
		{
            PFObject *patron = [currentUser valueForKey:@"Patron"];
            [patron fetchIfNeededInBackgroundWithBlock:^(PFObject *result, NSError *error)
			{
                if (!error) {
                    [sharedData setPatron:result];
                    [self presentTabBarController];
                }
                else {
                    NSLog(@"Failed to fetch Patron object: %@", error);
                }
            }];
			
        }
		else
		{
            [self presentTabBarController];
		}
		
    } else {
		[self presentLandingViews];
    }
}

- (void)presentTabBarController
{
    // create tab bar controller its child view controllers
    myPlacesVC = [[MyPlacesViewController alloc] init];
    inboxVC = [[InboxViewController alloc] init];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[myPlacesVC, inboxVC];
    
    UITabBarItem *myPlacesTab = [self.tabBarController.tabBar.items objectAtIndex:0];
    [myPlacesTab setTitle:@"My Places"];
    [myPlacesTab setImage:[UIImage imageNamed:@"ico-tab-places.png"]];
    
	UITabBarItem *inboxTab = [self.tabBarController.tabBar.items objectAtIndex:1];
    [inboxTab setTitle:@"Inbox"];
    [inboxTab setImage:[UIImage imageNamed:@"ico-tab-inbox.png"]];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    [attributes setValue:[UIFont fontWithName:@"Avenir-Heavy" size:12] forKey:UITextAttributeFont];
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	
	[inboxVC view]; //pre-load second tab
}

- (void)presentLandingViews
{
	landingVC = [[LandingViewController alloc] init];
	self.window.rootViewController = landingVC;
	[self.window makeKeyAndVisible];
	//self.navController = [[UINavigationController alloc] initWithRootViewController:landingVC];
	//self.window.rootViewController = self.navController;
    //[self.window makeKeyAndVisible];
}

- (void)logout
{
	[sharedData clearData];
    [PFUser logOut];
	//TODO: unload tab bar controller so it isn't see through when you go to register/login
	[self presentLandingViews];
}

@end
