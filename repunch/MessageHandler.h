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

+ (void) handlePush:(NSDictionary *)pushPayload;
+ (void) handleGiftPush:(NSDictionary *)pushPayload forReply:(BOOL)isReply;

@end
