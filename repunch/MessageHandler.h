//
//  MessageHandler.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/14/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"
#import "SIAlertView.h"

@interface MessageHandler : NSObject

+ (void) handlePush:(NSDictionary *)userInfo
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void) handleGiftPush:(NSDictionary *)userInfo
			   forReply:(BOOL)isReply
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
