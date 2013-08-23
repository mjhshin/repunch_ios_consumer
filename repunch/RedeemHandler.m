//
//  RedeemHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RedeemHandler.h"

@implementation RedeemHandler

+ (void) handlePush:(NSDictionary *)pushPayload
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = [pushPayload objectForKey:@"store_id"];
	NSString *rewardTitle = [pushPayload objectForKey:@"reward_title"];
	int totalPunches = [[pushPayload objectForKey:@"total_punches"] intValue];
	NSString *alert = [[pushPayload objectForKey:@"aps"] objectForKey:@"alert"];
	
	PFObject *patron = [sharedData patron];
	PFObject *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];
	
	if(store != nil && patronStore != nil)
	{
		int currentPunches = [[patronStore objectForKey:@"punch_count"] intValue];
		
		if(totalPunches < currentPunches) {
			[sharedData updatePatronStore:storeId withPunches:totalPunches];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Redeem" object:self];
		
		if( [patron objectForKey:@"facebook_id"] == nil )
		{
			SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Success!" andMessage:alert];
			[alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
			[alertView show];
		}
		else
		{
			[FacebookUtils postToFacebook:storeId withRewardTitle:rewardTitle];
		}
	}
	else
	{
		// User must have deleted the store from My Places. In that case, there's no need to notify them of anything.
	}
}

+ (void) handleOfferGiftPush:(NSDictionary *)pushPayload
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *msgStatusId = [pushPayload objectForKey:@"message_status_id"];
	NSString *alert = [[pushPayload objectForKey:@"aps"] objectForKey:@"alert"];
	
	PFObject *messageStatus = [sharedData getMessage:msgStatusId];
	[messageStatus setObject:@"no" forKey:@"redeem_available"];
	
	SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Success!" andMessage:alert];
	[alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
	[alertView show];
}

@end
