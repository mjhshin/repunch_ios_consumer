//
//  RPMessage.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPMessage.h"
#import <Parse/PFObject+Subclass.h>

@implementation RPMessage

@dynamic Reply;
@dynamic message_type;
@dynamic sender_name;
@dynamic subject;
@dynamic body;
@dynamic gift_title;
@dynamic gift_description;
@dynamic offer_title;
@dynamic date_offer_expiration;
@dynamic patron_id;
@dynamic store_id;
@dynamic is_read;

+ (NSString *)parseClassName
{
    return @"Message";
}

- (RPMessageType)type
{
	if([self.message_type isEqualToString:kMessageTypeOffer]) {
		return RPMessageTypeOffer;
	}
	else if([self.message_type isEqualToString:kMessageTypeFeedback]) {
		return RPMessageTypeFeedback;
	}
	else if([self.message_type isEqualToString:kMessageTypeGift]) {
		return RPMessageTypeGift;
	}
	else {
		return RPMessageTypeBasic;
	}
}

@end
