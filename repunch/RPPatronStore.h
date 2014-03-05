//
//  RPPatronStore.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/7/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPPatron.h"
#import "RPStore.h"
#import "RPFacebookPost.h"

@interface RPPatronStore : PFObject <PFSubclassing>

@property (assign, readonly, atomic) BOOL pending_reward;
@property (assign, readonly, atomic) NSInteger all_time_punches;
@property (assign, readonly, atomic) NSInteger punch_count;

@property (strong, readonly, atomic) RPPatron *Patron;
@property (strong, readonly, atomic) RPStore *Store;
@property (strong, atomic) RPFacebookPost *FacebookPost;

+ (NSString *)parseClassName;

@end
