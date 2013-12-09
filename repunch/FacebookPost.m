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
#import "RPConstants.h"

@implementation FacebookPost

+ (void) presentDialog:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle
{
	DataManager *sharedData = [DataManager getSharedInstance];
	RPStore *store = [sharedData getStore:storeId];
	PFObject *patronStore = [sharedData getPatronStore:storeId];
	int freePunches = store.punches_facebook;
	
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
 
+ (void) executePost:(RPStore *)store
	 withRewardTitle:(NSString *)rewardTitle
	  andPatronStore:(PFObject *)patronStore
		  andPunches:(int)punches
{
	PFFile *image = store.store_avatar;
	NSString *caption = [NSString stringWithFormat:@"At %@", store.store_name];

	NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
	[params setObject:@"Redeemed a reward using Repunch!"		forKey:@"name"];
	[params setObject:caption									forKey:@"caption"];
	[params setObject:rewardTitle								forKey:@"description"];
	[params setObject:@"https://www.repunch.com/"				forKey:@"link"];
	
	if(!IS_NIL(image)) {
		[params setObject:image.url								forKey:@"picture"];
	}
	
	[FBRequestConnection startWithGraphPath:@"me/feed"
								 parameters:params
								 HTTPMethod:@"POST"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		 if(!error)
		 {
			 [self callCloudCode:YES withPatronStore:patronStore andPunches:punches];
		 }
		 else
		 {
			 NSLog(@"FBRequestConnection POST error: %@", error);
			 [RepunchUtils showDialogWithTitle:@"Sorry, something went wrong" withMessage:nil];
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
				 
				 [RepunchUtils showDialogWithTitle:@"Successfully posted to Facebook" withMessage:nil];
			 }
		 }
		 else
		 {
			 NSLog(@"facebook_post error: %@", error);
			 [RepunchUtils showDialogWithTitle:@"Sorry, something went wrong" withMessage:nil];
		 }
	 }];
}

@end
