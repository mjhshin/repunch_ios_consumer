//
//  Message.h
//  repunch
//
//  Created by CambioLabs on 5/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@class User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * is_read;
@property (nonatomic, retain) NSString * retailer_id;
@property (nonatomic, retain) NSString * retailer_name;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * sent_time;
@property (nonatomic, retain) NSString * reply_body;
@property (nonatomic, retain) NSDate * reply_sent_time;
@property (nonatomic, retain) NSString * gift_sender_name;
@property (nonatomic, retain) NSString * gift_sender_username;
@property (nonatomic, retain) NSString * coupon_title;
@property (nonatomic, retain) NSDate * coupon_expire_time;
@property (nonatomic, retain) User *user;

- (void)setFromParse:(PFObject *)pfobject;

@end
