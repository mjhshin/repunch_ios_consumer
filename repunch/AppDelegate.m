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
	PFQuery *patronQuery;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	BOOL isProduction = NO; // DON'T FORGET TO SET!!!!
	
	if(isProduction) {	// PRODUCTION KEY
		[Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
					  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
	}
	else {				// DEVELOPMENT KEY
		[Parse setApplicationId:@"r9QrVhpx3wguChA9X9oe2GFGZwTUtrYyHOHpNWxb"
					  clientKey:@"2anJYVl8sakbPVqPz4MEbP2GLWBcs7uRFTvWMaZ0"];
	}
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	// Register Parse subclasses
	[RPInstallation registerSubclass];
	[RPUser registerSubclass];
	[RPPatron registerSubclass];
	[RPPatronStore registerSubclass];
    [RPStore registerSubclass];
	[RPStoreLocation registerSubclass];
	[RPMessage registerSubclass];
	[RPMessageStatus registerSubclass];
	[RPFacebookPost registerSubclass];

    [PFFacebookUtils initializeFacebook];
	
	[Crashlytics startWithAPIKey:@"87229bb388427a182709b79fc61e45ec5de14023"];
	[Crashlytics setBoolValue:isProduction forKey:@"is_production"];
	
	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
													UIRemoteNotificationTypeAlert |
													UIRemoteNotificationTypeSound];
	[RepunchUtils configureAppearance];
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
	RPInstallation *installation = [RPInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];
    [installation saveInBackground];
}

- (void)application:(UIApplication *)application
	didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{	
	if (error.code != 3010) { // 3010 indicates simulator, which cannot register for push
		CLS_LOG(@"AppDelegate didFailToRegisterForRemoteNotificationsWithError: %@", error);
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	[self handlePushWithPayload:userInfo fetchCompletionHandler:nil];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	[self handlePushWithPayload:userInfo fetchCompletionHandler:completionHandler];
}

- (void)handlePushWithPayload:(NSDictionary *)userInfo
	   fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	[RepunchUtils clearNotificationCenter];
	
	NSString *pushType = userInfo[@"type"];
	
	if( [pushType isEqualToString:@"punch"] ) {
		//NSLog(@"Push received: punch");
		[PunchHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
	else if( [pushType isEqualToString:@"redeem"] ) {
		//NSLog(@"Push received: redeem");
		[RedeemHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
	else if( [pushType isEqualToString:@"redeem_offer_gift"] ) {
		//NSLog(@"Push received: redeem offer/gift");
		[RedeemHandler handleOfferGiftPush:userInfo withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"message"] ) {
		//NSLog(@"Push received: message");
        [MessageHandler handlePush:userInfo withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"gift"] ) {
		//NSLog(@"Push received: gift");
		[MessageHandler handleGiftPush:userInfo forReply:NO withFetchCompletionHandler:completionHandler];
	}
    else if( [pushType isEqualToString:@"gift_reply"] ) {
		//NSLog(@"Push received: gift_reply");
		[MessageHandler handleGiftPush:userInfo forReply:YES withFetchCompletionHandler:completionHandler];
	}
}

- (void)checkLoginState
{
	RPUser* currentUser = [RPUser currentUser];
	
    if (currentUser) {
		
		[self presentIndeterminateStateView];
				
		RPPatron *patron = currentUser.Patron;
		
		if( IS_NIL(patron) ) {
			[RPUser logOut];
			[self checkLoginState];
		}
		else {
			patronQuery = [RPPatron query];
			patronQuery.cachePolicy = kPFCachePolicyCacheOnly;
			//BOOL isInCache = [patronQuery hasCachedResult];
			//NSLog(isInCache ? @"Yes - cached query" : @"No - cached query"); //Parse bug with hasCachedResult
		
			[patronQuery getObjectInBackgroundWithId:patron.objectId block:^(PFObject *patron, NSError *error) {
				
				 if (!error) {
					 [sharedData setPatron:(RPPatron *)patron];
					 [self presentTabBarController];
				 
					 //TODO: check installation's punch_code and patron_id
				 }
				 else {
					 CLS_LOG(@"AppDelegate checkLoginState - PFUser is cached but Patron is NOT cached: %@", error);
					 NSLog(@"AppDelegate checkLoginState - PFUser is cached but Patron is NOT cached: %@", error);
					 [RPUser logOut];
					 [self checkLoginState];
				 }
		 	}];
		}
    }
	else {
		[self presentLandingViews];
    }
}

- (void)presentIndeterminateStateView
{
	UIViewController *blankVC = [[UIViewController alloc] init];
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	blankVC.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LaunchImageSpinner"]];
	[blankVC.view addSubview:spinner];
	spinner.center = blankVC.view.center;
	
	CGRect frame = spinner.frame;
	frame.origin.y = blankVC.view.frame.size.height * 2/3 - 32.0f;
	spinner.frame = frame;
	
	[spinner startAnimating];
	self.window.rootViewController = blankVC;
    [self.window makeKeyAndVisible];
}

- (void)presentTabBarController
{
    [Crashlytics setUserName:[RPUser currentUser].username];

    MyPlacesViewController *myPlacesVC = [[MyPlacesViewController alloc] init];
    InboxViewController *inboxVC = [[InboxViewController alloc] init];
	
	RPNavigationController *myPlacesNavController = [[RPNavigationController alloc] initWithRootViewController:myPlacesVC];
	RPNavigationController *inboxNavController = [[RPNavigationController alloc] initWithRootViewController:inboxVC];
	[RepunchUtils setupNavigationController:myPlacesNavController];
	[RepunchUtils setupNavigationController:inboxNavController];
    
    myPlacesNavController.tabBarItem.title = @"My Places";
    inboxNavController.tabBarItem.title = @"Inbox";
    
    myPlacesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_my_places"];
    inboxNavController.tabBarItem.image = [UIImage imageNamed:@"tab_inbox"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = @[myPlacesNavController, inboxNavController];
	
	self.window.rootViewController = tabBarController;
	[self.window makeKeyAndVisible];
	
	//pre-load inbox tab
	[inboxVC view];
	
	//pre-load Facebook friend picker
	if([PFFacebookUtils isLinkedWithUser:[RPUser currentUser]]) {
		[FBFriendPickerViewController class];
	}
}

- (void)presentLandingViews
{
	LandingViewController *landingVC = [[LandingViewController alloc] init];
	RPNavigationController *navController = [[RPNavigationController alloc] initWithRootViewController:landingVC];
	[RepunchUtils setupNavigationController:navController];
	self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
}

- (void)logout
{
	[sharedData clearData];
    [RPUser logOut];
	[self presentLandingViews];
}

@end
