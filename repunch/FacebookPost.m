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
	//TODO: handle case when facebook permission changes
	
	DataManager *sharedData = [DataManager getSharedInstance];
	RPStore *store = [sharedData getStore:storeId];
	RPPatronStore *patronStore = [sharedData getPatronStore:storeId];
	
	NSString *title = [NSString stringWithFormat:@"Redeemed '%@'", rewardTitle];
	NSString *message = [NSString stringWithFormat:
						 @"Share this on Facebook to receive %@ extra punches?", store.punches_facebook];
	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
	
	[alert addButtonWithTitle:@"No"
						 type:SIAlertViewButtonTypeDefault
					  handler:^(SIAlertView *alert) {
						  
		[self callCloudCode:NO
			withPatronStore:patronStore
				withPunches:store.punches_facebook
			withRewardTitle:rewardTitle];
						  
		[alert dismissAnimated:YES];
	}];
	
	
	[alert addButtonWithTitle:@"Yes"
						 type:SIAlertViewButtonTypeDefault
					  handler:^(SIAlertView *alert) {
						  
		[self callCloudCode:YES
			withPatronStore:patronStore
				withPunches:store.punches_facebook
			withRewardTitle:rewardTitle];
						  
		[alert dismissAnimated:YES];
	}];
	
	[alert show];
}

+ (void) callCloudCode:(BOOL)accept
	   withPatronStore:(PFObject *)patronStore
		   withPunches:(NSNumber *)punches
	   withRewardTitle:(NSString *)rewardTitle
{
	NSString *acceptString = (accept) ? @"true" : @"false";  //NSDictionary only stores objects not primitives
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							   patronStore.objectId,		@"patron_store_id",
							   rewardTitle,					@"reward_title",
							   acceptString,				@"accept",
							   punches,						@"free_punches",
							   nil];
	
	[PFCloud callFunctionInBackground: @"post_to_facebook"
					   withParameters:inputArgs
								block:^(NSString *result, NSError *error)
	{
		 [RepunchUtils clearNotificationCenter];
		 
		 if(!error)
		 {
			 [patronStore setObject:[NSNull null] forKey:@"FacebookPost"];
			 
			 if(accept)
			 {
				 [patronStore incrementKey:@"punch_count" byAmount:punches];
				 [[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookPost" object:self];
				 
				 [RepunchUtils showDialogWithTitle:@"Successfully posted to Facebook" withMessage:nil];
			 }
		 }
		else if([[error userInfo][@"error"] isEqualToString:@"NULL_FACEBOOK_POST"])
		{
			NSLog(@"null fbook post");
		}
		 else
		 {
			 NSLog(@"facebook_post error: %@", error);
			 [RepunchUtils showDialogWithTitle:@"Sorry, something went wrong" withMessage:nil];
		 }
	 }];
}

@end
