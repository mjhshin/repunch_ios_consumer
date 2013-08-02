//
//  AppDelegate.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "AppDelegate.h"
#import "MyPlacesViewController.h"
#import "InboxViewController.h"
#import "LandingViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Crittercism.h"
#import "SIAlertView.h"
#import "SharedData.h"

@implementation AppDelegate {
    LandingViewController *landingVC;
    MyPlacesViewController *myPlacesVC;
    InboxViewController *inboxVC;
	SharedData* sharedData;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up API keys
    [Parse setApplicationId:@"m0EdwpRYlJwttZLZ5PUk7y13TWCnvSScdn8tfVoh"
                  clientKey:@"XZMybowaEMLHszQTEpxq4Yk2ksivkYj9m1c099ZD"];
    
    [PFFacebookUtils initializeFacebook];    
    [Crittercism enableWithAppID: @"51df08478b2e331138000003"];
	
    //Set up default settings for: sorting by alphabetical order, no notifications
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alphabetical Order", [NSNumber numberWithBool:NO], nil] forKeys:[NSArray arrayWithObjects:@"sort", @"notification", nil]]];

    //Register for Push Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSLog(@"%u",[[UIApplication sharedApplication] enabledRemoteNotificationTypes]);

    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif != nil) {
        NSLog(@"opened from push: %@", remoteNotif);
        // app was launched from push notification so open to the inbox
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPush" object:self]; //TODO: causing duplicate alert
        [self.tabBarController setSelectedIndex:2];
    }
	
	sharedData = [SharedData init];
    
	PFUser* currentUser = [PFUser currentUser];
	
    if (currentUser) {
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
		landingVC = [[LandingViewController alloc] init];
        self.window.rootViewController = landingVC;
    }
     
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //[MagicalRecord cleanUp];
}

#pragma mark - Push Notification methods

- (void)application:(UIApplication*)application
	didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
	// Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
	didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator. Ignore this
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
	/*
    [PFPush handlePush:userInfo];
    if ([[userInfo valueForKey:@"push_type"] isEqualToString:@"validate_redeem"]){
        if ([[_patron valueForKey:@"facebook_id"] length]>0){
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

    }*/
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedPush" object:self];
    
    
    //ideally, on push, add a button so on click will go directly to message
    //but can't do this, because not all views implement the modal delegate protocol
    //so message might possibly be able to dismiss
    //in the long run, it's probably better to switch to navigation based controller
    
    /*
    if ([[userInfo valueForKey:@"push_type"] isEqualToString:@"receive_message"]) {
        NSString *messageStatusIdString = [userInfo valueForKey:@"message_status_id"];
        PFQuery *messageStatusQuery = [PFQuery queryWithClassName:@"MessageStatus"];
        [messageStatusQuery includeKey:@"Message"];
        [messageStatusQuery includeKey:@"Message.Reply"];
        
        [messageStatusQuery getObjectInBackgroundWithId:messageStatusIdString block:^(PFObject *fetchedMessageStatus, NSError *error) {
            MessageViewController *messageVC = [[MessageViewController alloc] init];
            messageVC.modalDelegate = [[self window] rootViewController];
            messageVC.message = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.customerName = [NSString stringWithFormat:@"%@ %@", [_localUser first_name], [_localUser last_name]];
            messageVC.patronId = [_localUser patronId];
            messageVC.messageType = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            messageVC.messageStatus = fetchedMessageStatus;
            
            self.window.rootViewController = messageVC;
            
        }];


    }
    
    if ([[userInfo valueForKey:@"push_type"] isEqualToString:@"receive_gift"]) {
        NSString *messageStatusIdString = [userInfo valueForKey:@"message_status_id"];
        PFQuery *messageStatusQuery = [PFQuery queryWithClassName:@"MessageStatus"];
        [messageStatusQuery includeKey:@"Message"];
        [messageStatusQuery includeKey:@"Message.Reply"];
        
        [messageStatusQuery getObjectInBackgroundWithId:messageStatusIdString block:^(PFObject *fetchedMessageStatus, NSError *error) {
            MessageViewController *messageVC = [[MessageViewController alloc] init];
            messageVC.modalDelegate = [[self window] rootViewController];
            messageVC.message = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.customerName = [NSString stringWithFormat:@"%@ %@", [_localUser first_name], [_localUser last_name]];
            messageVC.patronId = [_localUser patronId];
            messageVC.messageType = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            messageVC.messageStatus = fetchedMessageStatus;
            
            self.window.rootViewController = messageVC;

        }];
    }

    if ([[userInfo valueForKey:@"push_type"] isEqualToString:@"receive_gift_reply"]) {
        NSString *messageStatusIdString = [userInfo valueForKey:@"message_status_id"];
        PFQuery *messageStatusQuery = [PFQuery queryWithClassName:@"MessageStatus"];
        [messageStatusQuery includeKey:@"Message"];
        [messageStatusQuery includeKey:@"Message.Reply"];
        
        [messageStatusQuery getObjectInBackgroundWithId:messageStatusIdString block:^(PFObject *fetchedMessageStatus, NSError *error) {
            MessageViewController *messageVC = [[MessageViewController alloc] init];
            messageVC.modalDelegate = [[self window] rootViewController];
            messageVC.message = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.customerName = [NSString stringWithFormat:@"%@ %@", [_localUser first_name], [_localUser last_name]];
            messageVC.patronId = [_localUser patronId];
            messageVC.messageType = [fetchedMessageStatus objectForKey:@"Message"];
            messageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            messageVC.messageStatus = fetchedMessageStatus;
            
            self.window.rootViewController = messageVC;

        }];

     
    }*/
    
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


//A function for parsing URL parameters.
- (NSDictionary*)parseURLParams:(NSString*)query {
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
}

- (void)logout
{
    [PFUser logOut];
	landingVC = [[LandingViewController alloc] init];
	self.window.rootViewController = landingVC;
}

@end
