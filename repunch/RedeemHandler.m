//
//  RedeemHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RedeemHandler.h"
#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "SIAlertView.h"
#import "FacebookPost.h"
#import "RPConstants.h"
#import "RepunchUtils.h"

@implementation RedeemHandler

+ (void) handlePush:(NSDictionary *)userInfo
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = userInfo[@"store_id"];
	NSString *rewardTitle = userInfo[@"reward_title"];
	NSInteger totalPunches = [userInfo[@"total_punches"] integerValue];
	NSString *alert = userInfo[@"aps"][@"alert"];
	
	RPStore *store = [sharedData getStore:storeId];
	RPPatronStore *patronStore = [sharedData getPatronStore:storeId];
	
	if(store != nil && patronStore != nil)
	{
		if(totalPunches < patronStore.punch_count) {
			[sharedData updatePatronStore:storeId withPunches:totalPunches];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Redeem" object:self];

		if( [PFFacebookUtils isLinkedWithUser:[RPUser currentUser]] &&  store.punches_facebook > 0)
		{
			[FacebookPost presentDialog:storeId withRewardTitle:rewardTitle];
		}
		else
		{
			[RepunchUtils showDialogWithTitle:@"Success!" withMessage:alert];
		}
	}
	else
	{
		// User must have deleted the store from My Places. In that case, there's no need to notify them of anything.
	}
	
	completionHandler(UIBackgroundFetchResultNoData);
}

+ (void) handleOfferGiftPush:(NSDictionary *)userInfo
  withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *msgStatusId = userInfo[@"message_status_id"];
	NSString *alert = userInfo[@"aps"][@"alert"];
	
	RPMessageStatus *messageStatus = [sharedData getMessage:msgStatusId];
	[messageStatus setObject:@"no" forKey:@"redeem_available"];
	
	[RepunchUtils showDialogWithTitle:@"Success!" withMessage:alert];
	
	completionHandler(UIBackgroundFetchResultNoData);
}

@end
