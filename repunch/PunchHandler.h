//
//  PunchHandler.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/9/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "DataManager.h"
#import "SIAlertView.h"

@interface PunchHandler : NSObject

+ (void) handlePush:(NSDictionary *)pushPayload;

@end
