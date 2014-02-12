//
//  FacebookUtils.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/21/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "SIAlertView.h"
#import "RepunchUtils.h"
#import "RPConstants.h"

@interface FacebookPost : NSObject

+ (void) presentDialog:(NSString *)storeId withRewardTitle:(NSString *)rewardTitle;

+ (void) callCloudCode:(BOOL)accept
	   withPatronStore:(RPPatronStore *)patronStore
		   withPunches:(NSInteger)punches
	   withRewardTitle:(NSString *)rewardTitle;

@end
