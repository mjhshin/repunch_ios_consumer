//
//  PunchHandler.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

@interface PunchHandler : NSObject

+ (void) handlePush:(NSDictionary *)userInfo withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
