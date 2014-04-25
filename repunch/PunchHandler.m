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
#import "RepunchUtils.h"

@implementation PunchHandler

+ (void)handlePush:(NSDictionary *)userInfo withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DataManager *dataManager = [DataManager getSharedInstance];
	
	NSString *storeId = userInfo[@"store_id"];
	NSString *patronStoreId = userInfo[@"patron_store_id"];
	NSInteger totalPunches = [userInfo[@"total_punches"] integerValue];
	NSString *alert = userInfo[@"aps"][@"alert"];
	
	RPStore *store = [dataManager getStore:storeId];
	RPPatronStore *patronStore = [dataManager getPatronStore:storeId];

	if(store != nil && patronStore != nil)
	{
		if(totalPunches > patronStore.punch_count) {
			[dataManager updatePatronStore:storeId withPunches:totalPunches];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPunch object:self];
		[RepunchUtils showDialogWithTitle:@"Punch!" withMessage:alert];
		completionHandler(UIBackgroundFetchResultNoData);
	}
	else
	{
		PFQuery *query = [RPPatronStore query];
		[query includeKey:@"Store.store_locations"];
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
				RPPatronStore *patronStore = (RPPatronStore *)result;
                //NSLog(@"Received punch where PatronStore/Store not in dataManager: %@", result);
                [dataManager addPatronStore:patronStore forKey:storeId];
                [dataManager addStore:patronStore.Store];
                
                NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:storeId, @"store_id", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPunch object:self userInfo:args];
				[RepunchUtils showDialogWithTitle:@"Punch!" withMessage:alert];
				completionHandler(UIBackgroundFetchResultNewData);
            }
        }];
	}
}

@end
