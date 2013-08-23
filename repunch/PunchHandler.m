//
//  PunchHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PunchHandler.h"

@implementation PunchHandler

+ (void)handlePush:(NSDictionary *)pushPayload
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = [pushPayload objectForKey:@"store_id"];
	NSString *patronStoreId = [pushPayload objectForKey:@"patron_store_id"];
	//int punches = [[pushPayload objectForKey:@"punches"] intValue];
	int totalPunches = [[pushPayload objectForKey:@"total_punches"] intValue];
	NSString *alert = [[pushPayload objectForKey:@"aps"] objectForKey:@"alert"];
	
	PFObject *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];

	if(store != nil && patronStore != nil)
	{
		int currentPunches = [[patronStore objectForKey:@"punch_count"] intValue];
		
		if(totalPunches > currentPunches) {
			[sharedData updatePatronStore:storeId withPunches:totalPunches];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self];
		
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Punch!" andMessage:alert];
		[alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
		[alertView show];
	}
	else
	{
		//delay notification if possible
		
		PFQuery *query = [PFQuery queryWithClassName:@"PatronStore"];
		[query includeKey:@"Store"];
		[query includeKey:@"FacebookPost"];
		
		[query getObjectInBackgroundWithId:patronStoreId block:^(PFObject *result, NSError *error)
		{
            if(!result)
            {
                //handle error
                NSLog(@"PatronStore query failed.");
            }
            else
            {
                NSLog(@"Received punch where PatronStore/Store not in sharedData: %@", result);
                [sharedData addPatronStore:result forKey:storeId];
                [sharedData addStore:[result objectForKey:@"Store"]];
                
                NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:storeId, @"store_id", nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self userInfo:args];
				
				SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Punch!" andMessage:alert];
				[alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
				[alertView show];
            }
        }];
	}
}

@end
