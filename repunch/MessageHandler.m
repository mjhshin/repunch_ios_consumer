//
//  MessageHandler.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/14/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MessageHandler.h"

@implementation MessageHandler

+ (void)handlePush:(NSDictionary *)pushPayload
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
	NSString *storeId = [pushPayload objectForKey:@"store_id"];
    NSString *messageId = [pushPayload objectForKey:@"message_id"];
    
    PFQuery *msgQuery = [PFQuery queryWithClassName:@"Message"];
    [msgQuery whereKey:@"objectId" equalTo:messageId];
    
    PFRelation *relation = [[sharedData patron] relationforKey:@"ReceivedMessages"];
    PFQuery *msgStatusQuery = [relation query];
    [msgStatusQuery includeKey:@"Message.Reply"];
    [msgStatusQuery whereKey:@"Message" matchesQuery:msgQuery];
    
    [msgStatusQuery getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error)
    {
        if (!result)
        {
            NSLog(@"MessageStatus query failed.");
        }
        else
        {
            [sharedData addMessage:result];
            
            NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:storeId, @"store_id", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Message" object:self userInfo:args];
        }
    }];
}

@end
