//
//  FacebookUtils.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/21/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@interface FacebookPost : NSObject

+ (void) presentDialog:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle;

+ (void) executePost:(PFObject *)store
	 withRewardTitle:(NSString *)rewardTitle
	  andPatronStore:(PFObject *)patronStore
		  andPunches:(int)punches;

+ (void) callCloudCode:(BOOL)accept withPatronStore:(PFObject *)patronStore andPunches:(int)punches;

@end
