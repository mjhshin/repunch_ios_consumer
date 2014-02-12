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
@synthesize avatar;

@dynamic active;
@dynamic thumbnail_image;
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

- (void)updateStoreImageWithCompletionHander:(StoreImageUpdateHandler)handler
{
	if( IS_NIL(self.thumbnail_image) ) {
		BLOCK_SAFE_RUN(handler, nil, nil);
		return;
	}
    __weak typeof(self) weakSelf = self;
    
    [self.thumbnail_image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            avatar = [UIImage imageWithData:data];
			[[DataManager getSharedInstance] addStoreImage:avatar forKey:weakSelf.objectId];
            BLOCK_SAFE_RUN(handler, weakSelf.avatar, error);
        }
        else {
            BLOCK_SAFE_RUN(handler, nil, error);
        }
    }];
}

@end
