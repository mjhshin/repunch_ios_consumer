//
//  RPFacebookPost.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPPatron.h"

@interface RPFacebookPost : PFObject <PFSubclassing>

@property (assign, atomic, readonly) BOOL posted;
@property (strong, atomic, readonly) RPPatron *Patron;
@property (strong, atomic, readonly) NSString *reward;

+ (NSString *)parseClassName;

@end
