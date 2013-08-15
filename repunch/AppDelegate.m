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
    [self.window makeKeyAndVisible];
	
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

#pragma mark - Facebook SDK helper methods
/*
- (void)publishButtonActionWithParameters:(NSDictionary*)userInfo
{
    PFQuery *getStore = [PFQuery queryWithClassName:@"Store"];
    [getStore getObjectInBackgroundWithId:[userInfo valueForKey:@"id"] block:^(PFObject *fetchedStore, NSError *error) {
        NSString *picURL = [[fetchedStore objectForKey:@"store_avatar"] url];
        
        // Put together the dialog parameters
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"Just redeemed %@ with Repunch", [userInfo valueForKey:@"title"]], @"name",
         [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"store"]], @"caption",
         picURL, @"picture",
         nil];
        
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                         NSDictionary *functionParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[userInfo valueForKey:@"patron_store_id"], @"patron_store_id", @"false", @"accept", nil];
                         [PFCloud callFunctionInBackground:@"facebook_post" withParameters:functionParameters block:^(id object, NSError *error) {
                             if (!error){
                                 NSLog(@"facebook function call is :%@", object);
                             }
                             else {
                                 NSLog(@"error is %@", error);
                             }
                         }];

                     } else {
                         // User clicked the Share button
                         NSString *msg = [NSString stringWithFormat:
                                          @"Posted the status!"];
                         NSLog(@"%@", msg);
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Yay! More punches for you!"
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil]
                          show];
                         
                         NSDictionary *functionParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[userInfo valueForKey:@"patron_store_id"], @"patron_store_id", @"true", @"accept", nil];
                         [PFCloud callFunctionInBackground:@"facebook_post" withParameters:functionParameters block:^(id object, NSError *error) {
                             if (!error){
                                 NSLog(@"facebook function call is :%@", object);
                                 
                             }
                             
                             else {
                                 NSLog(@"error is %@", error);
                             }
                         }];
                         
                     }
                 }
             }
         }];

        
    }];
    
}


//A function for parsing URL parameters.
- (NSDictionary*)parseURLParams:(NSString*)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
*/

- (void)checkLoginState
{
	PFUser* currentUser = [PFUser currentUser];
	
    if (currentUser)
	{
		//if patron object is null for some reason
        if ( ![sharedData patron] ) {
            PFObject *patron = [currentUser valueForKey:@"Patron"];
            [patron fetchIfNeededInBackgroundWithBlock:^(PFObject *result, NSError *error) {
                if (!error) {
                    [sharedData setPatron:result];
                    [self presentTabBarController];
                }
                else {
                    NSLog(@"Failed to fetch Patron object: %@", error);
                }
            }];
			
        } else {
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
    [attributes setValue:[UIFont fontWithName:@"Avenir" size:14] forKey:UITextAttributeFont];
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    self.window.rootViewController = self.tabBarController;
	
	[inboxVC view]; //pre-load second tab
}

- (void)presentLandingViews
{
	landingVC = [[LandingViewController alloc] init];
	self.window.rootViewController = landingVC;
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
