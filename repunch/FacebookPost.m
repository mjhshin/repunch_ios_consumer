//
//  FacebookUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/21/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "FacebookPost.h"
#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "SIAlertView.h"
#import "RepunchUtils.h"

@implementation FacebookPost

+ (void) presentDialog:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle
{
	DataManager *sharedData = [DataManager getSharedInstance];
	PFObject *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];
	int freePunches = [[store objectForKey:@"punches_facebook"] intValue];
	
	NSString *title = [NSString stringWithFormat:@"Redeemed '%@'", rewardTitle];
	NSString *message = [NSString stringWithFormat:
						 @"Share this on Facebook to receive %i extra punches?", freePunches];
	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
	
	[alert addButtonWithTitle:@"No"
						 type:SIAlertViewButtonTypeDefault
					  handler:^(SIAlertView *alert)
	{
		[self callCloudCode:NO withPatronStore:patronStore andPunches:freePunches];
		[alert dismissAnimated:YES];
	}];
	
	
	[alert addButtonWithTitle:@"Yes"
						 type:SIAlertViewButtonTypeDefault
					  handler:^(SIAlertView *alert)
	{
		[self executePost:store withRewardTitle:rewardTitle andPatronStore:patronStore andPunches:freePunches];
		[alert dismissAnimated:YES];
	}];
	[alert show];
}
 
+ (void) executePost:(PFObject *)store
	 withRewardTitle:(NSString *)rewardTitle
	  andPatronStore:(PFObject *)patronStore
		  andPunches:(int)punches
{
	PFFile *image = [store objectForKey:@"store_avatar"];
	NSString *caption = [NSString stringWithFormat:@"At %@", [store objectForKey:@"store_name"]];

	NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
	[params setObject:@"Redeemed a reward using Repunch!"		forKey:@"name"];
	[params setObject:caption									forKey:@"caption"];
	[params setObject:rewardTitle								forKey:@"description"];
	[params setObject:image.url									forKey:@"picture"];
	[params setObject:@"https://www.repunch.com/"				forKey:@"link"];
	
	[FBRequestConnection startWithGraphPath:@"me/feed"
								 parameters:params
								 HTTPMethod:@"POST"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	 {
		 if(!error)
		 {
			 [self callCloudCode:YES withPatronStore:patronStore andPunches:punches];
		 }
		 else
		 {
			 NSLog(@"FBRequestConnection POST error: %@", error);
			 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Sorry, something went wrong" andMessage:nil];
			 [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
			 [alert show];
		 }
	 }];
}

+ (void) callCloudCode:(BOOL)accept withPatronStore:(PFObject *)patronStore andPunches:(int)punches
{
	NSString *acceptString = accept ? @"true" : @"false"; //well, this is dumb.
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							   patronStore.objectId,	@"patron_store_id",
							   acceptString,			@"accept",
							   nil];
	
	[PFCloud callFunctionInBackground: @"facebook_post"
					   withParameters:inputArgs
								block:^(NSString *result, NSError *error)
	 {
		 [RepunchUtils clearNotificationCenter];
		 
		 if(!error)
		 {
			 [patronStore setObject:[NSNull null] forKey:@"FacebookPost"];
			 
			 if(accept)
			 {
				 [patronStore incrementKey:@"punch_count" byAmount:[NSNumber numberWithInt:punches]];
				 [[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookPost" object:self];
				 
				 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Successfully posted to Facebook" andMessage:nil];
				 [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
				 [alert show];
			 }
		 }
		 else
		 {
			 NSLog(@"facebook_post error: %@", error);
			 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Sorry, something went wrong" andMessage:nil];
			 [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
			 [alert show];
		 }
	 }];
}

@end
