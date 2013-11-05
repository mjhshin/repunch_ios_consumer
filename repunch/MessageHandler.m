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
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
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
    
    [msgStatusQuery getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        if (!result) {
            NSLog(@"MessageStatus query failed: %@", error);
			completionHandler(UIBackgroundFetchResultFailed);
        }
        else {
            [sharedData addMessage:result];
            
            NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:[result objectId], @"message_status_id", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Message"
																object:self
															  userInfo:args];
			
			[RepunchUtils showDialogWithTitle:@"New Message" withMessage:alert];
			
			completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}

+ (void)handleGiftPush:(NSDictionary *)pushPayload
			  forReply:(BOOL)isReply
withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DataManager *sharedData = [DataManager getSharedInstance];
	
    NSString *messageStatusId = [pushPayload objectForKey:@"message_status_id"];
	NSString *alert = [[pushPayload objectForKey:@"aps"] objectForKey:@"alert"];
    
    PFQuery *msgStatusQuery = [PFQuery queryWithClassName:@"MessageStatus"];
    [msgStatusQuery includeKey:@"Message.Reply"];
    
    [msgStatusQuery getObjectInBackgroundWithId:messageStatusId block:^(PFObject *result, NSError *error) {
		if (!result) {
			NSLog(@"MessageStatus query failed: %@", error);
			completionHandler(UIBackgroundFetchResultFailed);
		}
		else {
			[sharedData addMessage:result];
			
			NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:[result objectId], @"message_status_id", nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Message"
																object:self
															  userInfo:args];
			
			if(isReply) {
				[RepunchUtils showDialogWithTitle:@"New Message" withMessage:alert];
			}
			else {
				[RepunchUtils showDialogWithTitle:@"You received a gift!" withMessage:alert];
			}
			
			completionHandler(UIBackgroundFetchResultNewData);
		}
		
	}];
}

@end
