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
@dynamic store_avatar;
@dynamic rewards;
@dynamic categories;
@dynamic store_name;
@dynamic punches_facebook;
@dynamic StoreLocations;

#pragma mark - Parse

+ (NSString *)parseClassName
{
    return @"Store";
}

- (void)updateStoreAvatarWithCompletionHander:(StoreAvatarUpdateHandler)handler
{
	if( IS_NIL(self.store_avatar) ) {
		BLOCK_SAFE_RUN(handler, nil, nil);
		return;
	}
    __weak typeof(self) weakSelf = self;
    
    [self.store_avatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
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
