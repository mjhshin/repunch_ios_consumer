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

@interface PunchHandler : NSObject

+ (void) handlePunch:(NSDictionary *)pushPayload;

@end
