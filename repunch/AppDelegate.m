//
//  AppDelegate.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"

#import "PlacesViewController.h"
#import "InboxViewController.h"
#import "LoginViewController.h"

#import <Parse/Parse.h>

#import "Store.h"
#import "User.h"

@implementation AppDelegate{
    PlacesViewController *placesVC;
    InboxViewController *inboxVC;
    LoginViewController *loginVC;
}

//JUST FOR MY OWN SANITY, what's goingon:
//on launch: set up parse API, (tbd) set up Facebook API, (tbd), set up Push notifications, set up tab view controller, and either send user to home page or login page.

//TODO ON THIS PAGE:
//INIT + FIGURE OUT ALL FACEBOOK SDK STUFF
//FIGURE OUT PUSH NOTIFICATION RESPONSE


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    //Set up API keys
    [Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
                  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"repunch_local.sqlite"];
    
    //Init Tab Bar and all related view controllers
    placesVC = [[PlacesViewController alloc] init];
    inboxVC = [[InboxViewController alloc] init];
    
    //Set up default settings for: sorting by alphabetical order, no notifications
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alphabetical Order", [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"sort", @"notification", nil]]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[placesVC, inboxVC];
    
    UITabBarItem *placeItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    [placeItem setTitle:@"Places"];
    [placeItem setImage:[UIImage imageNamed:@"ico-tab-places@2xsmall.png"]];
    
    UITabBarItem *inboxItem = [self.tabBarController.tabBar.items objectAtIndex:1];
    [inboxItem setTitle:@"Inbox"];
    [inboxItem setImage:[UIImage imageNamed:@"ico-tab-inbox@2xsmall.png"]];

    
    //Register for Push Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif != nil) {
        NSLog(@"opened from push: %@", remoteNotif);
        // app was launched from push notification so open to the inbox
        [self.tabBarController setSelectedIndex:2];
    }
    
    
//    [self deleteDataForObject:@"Store"];
//    [self printDataForObject:@"Store"];

    
    //[PFUser logOut];
    
    //if user is cached, load their local data
    //else, go to login page
    if ([PFUser currentUser])
    {
        //[placesVC loadPlaces];
        self.window.rootViewController = self.tabBarController;
    } else {
        loginVC = [[LoginViewController alloc] init];
        self.window.rootViewController = loginVC;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Core Data helper methods

-(void)deleteDataForObject:(NSString *)entityName{
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *objects;
    
    if ([entityName isEqualToString:@"Store"]){
        objects = [Store MR_findAll];
    }
    
    if ([entityName isEqualToString:@"User"]){
        objects = [User MR_findAll];
    }

    
    for (id object in objects){
        [context deleteObject:object];
    }
    
    [self saveContext];
}

-(void)printDataForObject:(NSString *)entityName{
    
    NSArray *objects;
    
    if ([entityName isEqualToString:@"Store"]){
        objects = [Store MR_findAll];
    }
    
    for (id object in objects){
        NSLog(@"%@", object);
    }
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

-(void)saveContext{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];
}

#pragma mark - Facebook SDK helper methods


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
