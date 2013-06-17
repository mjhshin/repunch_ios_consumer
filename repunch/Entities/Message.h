//
//  Message.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * is_read;
@property (nonatomic, retain) NSString * sender_name;
@property (nonatomic, retain) NSString * offer_title;
@property (nonatomic, retain) NSString * date_offer_expiration;
@property (nonatomic, retain) NSString * store_id;
@property (nonatomic, retain) Message *reply;

@end
