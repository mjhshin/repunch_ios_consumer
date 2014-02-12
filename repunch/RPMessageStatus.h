//
//  RPMessageStatus.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPMessage.h"

@interface RPMessageStatus : PFObject <PFSubclassing>

@property (strong, atomic, readonly) RPMessage *Message;
@property (strong, atomic) NSString *redeem_available;
@property (assign, atomic) BOOL is_read;

+ (NSString *)parseClassName;

@end
