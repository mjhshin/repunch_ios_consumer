//
//  PunchHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PunchHandler.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "DataManager.h"
#import "SIAlertView.h"
#import "RepunchUtils.h"

@implementation PunchHandler

+ (void)handlePush:(NSDictionary *)userInfo withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = [userInfo objectForKey:@"store_id"];
	NSString *patronStoreId = [userInfo objectForKey:@"patron_store_id"];
	int totalPunches = [[userInfo objectForKey:@"total_punches"] intValue];
	NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
	
	RPStore *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];

	if(store != nil && patronStore != nil)
	{
		int currentPunches = [[patronStore objectForKey:@"punch_count"] intValue];
		
		if(totalPunches > currentPunches) {
			[sharedData updatePatronStore:storeId withPunches:totalPunches];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self];
		[RepunchUtils showDialogWithTitle:@"Punch!" withMessage:alert];
		completionHandler(UIBackgroundFetchResultNoData);
	}
	else
	{
		PFQuery *query = [PFQuery queryWithClassName:@"PatronStore"];
		[query includeKey:@"Store"];
		[query includeKey:@"FacebookPost"];
		
		[query getObjectInBackgroundWithId:patronStoreId block:^(PFObject *result, NSError *error)
		{
            if(!result)
            {
                NSLog(@"PatronStore query failed: %@", error);
				completionHandler(UIBackgroundFetchResultFailed);
            }
            else
            {
                NSLog(@"Received punch where PatronStore/Store not in sharedData: %@", result);
                [sharedData addPatronStore:result forKey:storeId];
                [sharedData addStore:[result objectForKey:@"Store"]];
                
                NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:storeId, @"store_id", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self userInfo:args];
				[RepunchUtils showDialogWithTitle:@"Punch!" withMessage:alert];
				completionHandler(UIBackgroundFetchResultNewData);
            }
        }];
	}
}

@end
