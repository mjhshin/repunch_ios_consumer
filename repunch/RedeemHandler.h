//
//  RedeemHandler.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

@interface RedeemHandler : NSObject

+ (void) handlePush:(NSDictionary *)userInfo
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void) handleOfferGiftPush:(NSDictionary *)userInfo
  withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
