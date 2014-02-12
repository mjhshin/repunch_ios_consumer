//
//  RPMessage.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@interface RPMessage : PFObject <PFSubclassing>

@property (strong, atomic) RPMessage *Reply;

@property (strong, atomic, readonly) NSString *message_type;
@property (strong, atomic, readonly) NSString *sender_name;

@property (strong, atomic, readonly) NSString *subject; //going away?
@property (strong, atomic, readonly) NSString *body;

@property (strong, atomic, readonly) NSString *gift_title;
@property (strong, atomic, readonly) NSString *gift_description;

@property (strong, atomic, readonly) NSString *offer_title;
@property (strong, atomic, readonly) NSDate *date_offer_expiration;

@property (strong, atomic, readonly) NSString *patron_id;
@property (strong, atomic, readonly) NSString *store_id;

@property (assign, atomic) BOOL is_read;

//@property (strong, readonly, atomic) NSString *filter;
//@property (assign, readonly, atomic) NSString *receiver_count;

+ (NSString *)parseClassName;

@end