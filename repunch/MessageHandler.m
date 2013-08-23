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
	
    NSString *messageId = [pushPayload objectForKey:@"message_id"];
	NSString *alert = [[pushPayload objectForKey:@"aps"] objectForKey:@"alert"];
    
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
            
            NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:[result objectId], @"message_status_id", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Message"
																object:self
															  userInfo:args];
			
			SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"New Message" andMessage:alert];
			[alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
			[alertView show];
        }
    }];
}

@end
