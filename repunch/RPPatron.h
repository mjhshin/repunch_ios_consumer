//
//  RPPatron.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/7/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Parse/Parse.h>

@interface RPPatron : PFObject <PFSubclassing>

@property (strong, readonly, atomic) NSDate *date_of_birth;
@property (strong, readonly, atomic) NSString *facebook_id; //TODO: remove this column and use id from authdata in PFUser
@property (strong, readonly, atomic) NSString *first_name;
@property (strong, readonly, atomic) NSString *last_name;
@property (strong, readonly, atomic) NSString *gender;
@property (strong, readonly, atomic) NSString *punch_code;

@property (strong, readonly, atomic) NSString *full_name;

+ (NSString *)parseClassName;

@end
