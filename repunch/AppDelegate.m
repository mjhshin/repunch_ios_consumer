//
//  AppDelegate.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate
{
	DataManager* sharedData;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	//////////////////////////////////////////////////////////////////////////////////////
	//
	//                               PRODUCTION KEY
	//
    //[Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
    //              clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
	//
	//////////////////////////////////////////////////////////////////////////////////////
	//
	//                               DEVELOPMENT KEY
	//
	[Parse setApplicationId:@"r9QrVhpx3wguChA9X9oe2GFGZwTUtrYyHOHpNWxb"
                  clientKey:@"2anJYVl8sakbPVqPz4MEbP2GLWBcs7uRFTvWMaZ0"];
    //
	////////////////////////////////////////////////////////////////////////////////////////
	
    [PFFacebookUtils initializeFacebook];
	
	[Crashlytics startWithAPIKey:@"87229bb388427a182709b79fc61e45ec5de14023"];
	
	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
													UIRemoteNotificationTypeAlert |
													UIRemoteNotificationTypeSound];
	
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
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
	didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{	
	if (error.code != 3010) { // 3010 is for the iPhone Simulator. Ignore this
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	[RepunchUtils clearNotificationCenter];
	
	NSString *pushType = [userInfo objectForKey:@"type"];
	
	if( [pushType isEqualToString:@"punch"] )
	{
		NSLog(@"Push received: punch");
		[PunchHandler handlePush:userInfo withFetchCompletionHandler:nil];
	}
	else if( [pushType isEqualToString:@"redeem"] )
	{
		NSLog(@"Push received: redeem");
		[RedeemHandler handlePush:userInfo withFetchCompletionHandler:nil];
	}
	else if( [pushType isEqualToString:@"redeem_offer_gift"] )
	{
		NSLog(@"Push received: redeem offer/gift");
		[RedeemHandler handleOfferGiftPush:userInfo withFetchCompletionHandler:nil];
	}
    else if( [pushType isEqualToString:@"message"] )
	{
		NSLog(@"Push received: message");
        [MessageHandler handlePush:userInfo withFetchCompletionHandler:nil];
	}
    else if( [pushType isEqualToString:@"gift"] )
	{
		NSLog(@"Push received: gift");
		[MessageHandler handleGiftPush:userInfo forReply:NO withFetchCompletionHandler:nil];
	}
    else if( [pushType isEqualToString:@"gift_reply"] )
	{
		NSLog(@"Push received: gift_reply");
		[MessageHandler handleGiftPush:userInfo forReply:YES withFetchCompletionHandler:nil];
	}
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	[RepunchUtils clearNotificationCenter];
	
	NSString *pushType = [userInfo objectForKey:@"type"];
	
	if( [pushType isEqualToString:@"punch"] )
	{
		NSLog(@"Push received: punch");
		[PunchHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
	else if( [pushType isEqualToString:@"redeem"] )
	{
		NSLog(@"Push received: redeem");
		[RedeemHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
	else if( [pushType isEqualToString:@"redeem_offer_gift"] )
	{
		NSLog(@"Push received: redeem offer/gift");
		[RedeemHandler handleOfferGiftPush:userInfo withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"message"] )
	{
		NSLog(@"Push received: message");
        [MessageHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"gift"] )
	{
		NSLog(@"Push received: gift");
		[MessageHandler handleGiftPush:userInfo forReply:NO withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"gift_reply"] )
	{
		NSLog(@"Push received: gift_reply");
		[MessageHandler handleGiftPush:userInfo forReply:YES withFetchCompletionHandler:completionHandler];
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
			Reachability *reachability = [Reachability reachabilityForInternetConnection];
			NetworkStatus internetStatus = [reachability currentReachabilityStatus];
			
			if (internetStatus != NotReachable)
			{
				[self presentIndeterminateStateView];
				
				PFObject *patron = [currentUser objectForKey:@"Patron"];
				NSLog(@"object ID: %@", patron.objectId);
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
				
				//PFQuery *query;
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

- (void)presentIndeterminateStateView
{
	UIViewController *blankVC = [[UIViewController alloc] init];
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[blankVC.view setBackgroundColor:[UIColor blackColor]];
	[blankVC.view addSubview:spinner];
	spinner.center = blankVC.view.center;
	[spinner startAnimating];
	self.window.rootViewController = blankVC;
    [self.window makeKeyAndVisible];
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
	tabBarController.tabBar.barStyle = UIBarStyleDefault;
	
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
