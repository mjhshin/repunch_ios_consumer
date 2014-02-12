//
//  RPUser.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/12/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>
#import "RPPatron.h"

@interface RPUser : PFUser <PFSubclassing>

@property (strong, atomic, readonly) RPPatron *Patron;

// No need to implement this for PFUser
//+ (NSString *)parseClassName;

@end
