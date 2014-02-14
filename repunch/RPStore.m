//
//  Store.m
//  Repunch
//
//  Created by Emil on 9/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RPStore.h"
#import <Parse/PFObject+Subclass.h>
#import "DataManager.h"

@interface RPStore()

@end

@implementation RPStore

#pragma mark - Synthesize properties

@dynamic active;
@dynamic thumbnail_image;
@dynamic cover_image;
@dynamic rewards;
@dynamic categories;
@dynamic store_name;
@dynamic punches_facebook;
@dynamic store_locations;

#pragma mark - Parse

+ (NSString *)parseClassName
{
    return @"Store";
}

@end
