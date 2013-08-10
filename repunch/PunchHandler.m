//
//  PunchHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PunchHandler.h"

@implementation PunchHandler

+ (void)handlePunch:(NSDictionary *)pushPayload
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = [pushPayload objectForKey:@"id"];
	PFObject *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];
	int punches = [[pushPayload objectForKey:@"punches"] intValue];
	int totalPunches = [[pushPayload objectForKey:@"total_punches"] intValue];
	
	if(store == nil)
	{
		//download store
	}
	else
	{
		
	}
	
	if(patronStore == nil)
	{
		//download patronStore - update punch function to send PatronStore.objectId??
	}
	else
	{
		
	}
	
	if(store != nil && patronStore != nil)
	{
		[sharedData updatePatronStore:storeId withPunches:totalPunches];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self];
	}
}

- (void)downloadStore:(NSString *)storeId
{
	
}

@end
