//
//  AppDelegate.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>

#import "PlacesViewController.h"
#import "PunchViewController.h"
#import "InboxNavigationController.h"
#import "InboxViewController.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "Retailer.h"
#import "Reward.h"

@implementation AppDelegate

@synthesize session, loginVC, fbUser, localUser, placesVC;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [loginVC release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //Set up API keys
    [Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
                  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
        
    [PFFacebookUtils initializeFacebook];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"repunch_local.sqlite"];

    //Init Tab Bar and all related view controllers
    placesVC = [[[PlacesViewController alloc] init] autorelease];
    PunchViewController *punchVC = [[[PunchViewController alloc] init] autorelease];
    InboxViewController *inboxVC = [[[InboxViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    InboxNavigationController *inboxNavVC = [[[InboxNavigationController alloc] initWithRootViewController:inboxVC] autorelease];
    [inboxNavVC.navigationBar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forBarMetrics:UIBarMetricsDefault];
    
    //Set up default settings for: sorting by alphabetical order, no notifications
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alphabetical Order", [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"sort", @"notification", nil]]];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[placesVC, punchVC, inboxNavVC];
    
    //Register for Push Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif != nil) {
        NSLog(@"opened from push: %@", remoteNotif);
        // app was launched from push notification so open to the inbox
        [self.tabBarController setSelectedIndex:2];
    }
    
    //if user is cached, load their local data
    //else, go to login page
    if ([PFUser currentUser])
    {
        [placesVC loadPlaces];
        self.window.rootViewController = self.tabBarController;
    } else {
        loginVC = [[LandingViewController alloc] init];
        self.window.rootViewController = loginVC;
    }

    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Facebook SDK helper methods

- (void)sessionDidOpen
{
    self.window.rootViewController = self.tabBarController;
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             self.fbUser = user;
         } else {
             NSLog(@"requestForMe error: %@",error);
         }
     }];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.session close];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  NSLog(@"open access token error: %@",error);
                              }
                          }];
}

#pragma mark - Tab controller helper methods
-(void)makeTabBarHidden:(BOOL)hide {
	// Custom code to hide TabBar
	if ( [self.tabBarController.view.subviews count] < 2 ) {
		return;
	}
	
	UIView *contentView;
	
	if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] ) {
		contentView = [self.tabBarController.view.subviews objectAtIndex:1];
	} else {
		contentView = [self.tabBarController.view.subviews objectAtIndex:0];
	}
	
	if (hide) {
		contentView.frame = self.tabBarController.view.bounds;
	}
	else {
		contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
									   self.tabBarController.view.bounds.origin.y,
									   self.tabBarController.view.bounds.size.width,
									   self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
	}
	
	self.tabBarController.tabBar.hidden = hide;
}

#pragma mark - Push Notification methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notification"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];

}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    if ([application applicationState] == UIApplicationStateInactive) {
        // app opened from suspended on push, open to inbox
        [[(AppDelegate *)application.delegate tabBarController] setSelectedIndex:2];
    } else if ([application applicationState] == UIApplicationStateActive) {
        // push received when app already open, so alert?
    }
}

@end
