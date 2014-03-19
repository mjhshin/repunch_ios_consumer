//
//  FacebookUtils.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/21/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "FacebookPost.h"
#import "RPCustomAlertController.h"

@implementation FacebookPost

+ (void) presentDialog:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle
{
	//TODO: handle case when facebook permission changes
	
	DataManager *dataManager = [DataManager getSharedInstance];
	RPStore *store = [dataManager getStore:storeId];
	RPPatronStore *patronStore = [dataManager getPatronStore:storeId];
	
	NSString *title = [NSString stringWithFormat:@"Redeemed '%@'", rewardTitle];
	NSString *message = [NSString stringWithFormat:
						 @"Share this on Facebook to receive %d extra punches?", store.punches_facebook];
	
	[RPCustomAlertController showDecisionAlertWithTitle:title
											 andMessage:message
											   andBlock:^(RPCustomAlertController *alert, RPCustomAlertActionButton buttonType, id anObject) {
        [alert hideAlertWithBlock:^{
            if (buttonType == ConfirmButton) {

                [self callCloudCode:YES
                    withPatronStore:patronStore
                        withPunches:store.punches_facebook
                    withRewardTitle:rewardTitle];

            }
            else if (buttonType == DenyButton) {
                [self callCloudCode:NO
                    withPatronStore:patronStore
                        withPunches:store.punches_facebook
                    withRewardTitle:rewardTitle];
            }
        }];
    }];
}

+ (void) callCloudCode:(BOOL)accept
	   withPatronStore:(RPPatronStore *)patronStore
		   withPunches:(NSInteger)punches
	   withRewardTitle:(NSString *)rewardTitle
{
	NSString *acceptString = (accept) ? @"true" : @"false";  //NSDictionary only stores objects not primitives
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							   patronStore.objectId,					@"patron_store_id",
							   rewardTitle,								@"reward_title",
							   acceptString,							@"accept",
							   [NSNumber numberWithInteger:punches],	@"free_punches",
							   nil];
	
	[PFCloud callFunctionInBackground: @"post_to_facebook"
					   withParameters:inputArgs
								block:^(NSString *result, NSError *error) {
		[RepunchUtils clearNotificationCenter];
		
		if(!error) {
			patronStore.FacebookPost = nil;//[NSNull null];
			
			if(accept) {
				[patronStore incrementKey:@"punch_count" byAmount:[NSNumber numberWithInteger:punches]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookPost" object:self];
				
				[RepunchUtils showDialogWithTitle:@"Successfully posted to Facebook" withMessage:nil];
			}
		}
		else if([[error userInfo][@"error"] isEqualToString:@"NULL_FACEBOOK_POST"]) {
			patronStore.FacebookPost = nil;//[NSNull null];
			[RepunchUtils showDialogWithTitle:@"You've already shared this redeem on Facebook" withMessage:nil];
		}
		else {
			NSLog(@"facebook_post error: %@", error);
			[RepunchUtils showDialogWithTitle:@"Sorry, something went wrong" withMessage:nil];
		}
	}];
}

@end
