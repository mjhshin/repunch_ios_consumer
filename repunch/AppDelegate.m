//
//  AppDelegate.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/1/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"
#import "PlacesViewController.h"
#import "LoginViewController.h"
#import "InboxViewController.h"

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

#import "Store.h"
#import "User.h"
#import "PatronStore.h"

#import "SIAlertView.h"


#import "LandingViewController.h"
@implementation AppDelegate{
    LoginViewController *loginVC;
    PlacesViewController *placesVC;
    InboxViewController *inboxVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up API keys
    [Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
                  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
    
    [PFFacebookUtils initializeFacebook];
    
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
    
    NSLog(@"%u",[[UIApplication sharedApplication] enabledRemoteNotificationTypes]);

    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif != nil) {
        NSLog(@"opened from push: %@", remoteNotif);
        // app was launched from push notification so open to the inbox
        [self.tabBarController setSelectedIndex:2];
    }
    
    
    [PFUser logOut];
    
    //if user is cached, load their cached data
    //else, go to login page
    if ([PFUser currentUser])
    {
        _localUser = [User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser]username]];
        
        NSLog(@"user:%@", [_localUser username]);
        
        if (!_patronObject){
            PFObject *patronObject = [[PFUser currentUser] valueForKey:@"Patron"];
            
            [patronObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatronObject, NSError *error) {
                _patronObject = fetchedPatronObject;
                if (!_localUser){
                    _localUser = [User MR_createEntity];
                    [_localUser setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatronObject];
                }
                
                self.window.rootViewController = self.tabBarController;
            }];
        }
        else
            self.window.rootViewController = self.tabBarController;
    } else {
        LandingViewController *landingVC = [[LandingViewController alloc] init];
        self.window.rootViewController = landingVC;
    }
    
     
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}



#pragma mark - Push Notification methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notification"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [PFPush handlePush:userInfo];
    if ([[userInfo valueForKey:@"punch_type"] isEqualToString:@"validate_redeem"]){
        if ([[_patronObject valueForKey:@"facebook_id"] length]>0){
            SIAlertView *alertView = [[SIAlertView alloc]initWithTitle:@"Want More Punches?" andMessage:@"Would you like to post to Facebook to receive more punches?"];
            [alertView addButtonWithTitle:@"No thanks." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                NSDictionary *functionParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[userInfo valueForKey:@"patron_store_id"], @"patron_store_id", @"false", @"accept", nil];
                [PFCloud callFunctionInBackground:@"facebook_post" withParameters:functionParameters block:^(id object, NSError *error) {
                    if (!error){
                        NSLog(@"facebook function call is :%@", object);
                    }
                    else {
                        NSLog(@"error is %@", error);
                    }
                }];

            }];
            
            [alertView addButtonWithTitle:@"Sure!" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                [self publishButtonActionWithParameters:userInfo];

            }];
            
            [alertView show];
            
        }

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPush" object:self];
    
}
#pragma mark - Facebook SDK helper methods

- (void)publishButtonActionWithParameters:(NSDictionary*)userInfo{
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

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
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


-(void)logout{
    [PFUser logOut];
    self.window.rootViewController = loginVC;
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
