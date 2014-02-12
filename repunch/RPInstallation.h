//
//  RPInstallation.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/12/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@interface RPInstallation : PFInstallation <PFSubclassing>

@property (strong, atomic) NSString *patron_id;
@property (strong, atomic) NSString *punch_code;

// No need to implement this for PFInstallation
//+ (NSString *)parseClassName;

@end
