//
//  Message.m
//  repunch
//
//  Created by CambioLabs on 5/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "Message.h"
#import "User.h"


@implementation Message

@dynamic is_read;
@dynamic retailer_id;
@dynamic retailer_name;
@dynamic subject;
@dynamic type;
@dynamic body;
@dynamic sent_time;
@dynamic reply_body;
@dynamic reply_sent_time;
@dynamic gift_sender_name;
@dynamic gift_sender_username;
@dynamic coupon_title;
@dynamic coupon_expire_time;
@dynamic user;

- (void)setFromParse:(PFObject *)pfobject
{
    self.objectId = [pfobject objectId];
    self.type = [pfobject objectForKey:@"type"];
    self.is_read = [pfobject objectForKey:@"is_read"];
    self.retailer_id = [pfobject objectForKey:@"retailer_id"];
    self.retailer_name = [pfobject objectForKey:@"retailer_name"];
    self.subject = [pfobject objectForKey:@"subject"];
    self.body = [pfobject objectForKey:@"body"];
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    
    self.sent_time = [df dateFromString:[pfobject objectForKey:@"sent_time"]];
    self.reply_sent_time = [df dateFromString:[pfobject objectForKey:@"reply_sent_time"]];

    self.reply_body = [pfobject objectForKey:@"reply_body"];
    self.gift_sender_name = [pfobject objectForKey:@"gift_sender_name"];
    self.gift_sender_username = [pfobject objectForKey:@"gift_sender_username"];
    self.coupon_title = [pfobject objectForKey:@"coupon_title"];
    self.coupon_expire_time = [pfobject objectForKey:@"coupon_expire_time"];
}

@end
