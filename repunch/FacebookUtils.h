//
//  FacebookUtils.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/21/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "SIAlertView.h"

@interface FacebookUtils : NSObject

+ (void) postToFacebook:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle;

+ (void) executePost:(PFObject *)store
	 withRewardTitle:(NSString *)rewardTitle
	  andPatronStore:(PFObject *)patronStore
		  andPunches:(int)punches;

+ (void) callCloudCode:(BOOL)accept withPatronStore:(PFObject *)patronStore andPunches:(int)punches;

@end
