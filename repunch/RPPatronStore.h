//
//  RPPatronStore.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/7/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@interface RPPatronStore : PFObject <PFSubclassing>

@property (assign, readonly, atomic) BOOL pending_reward;
@property (strong, readonly, atomic) NSNumber *all_time_punches;
@property (strong, readonly, atomic) NSNumber *punch_count;

+ (NSString *)parseClassName;

@end
