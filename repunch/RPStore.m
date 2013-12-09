//
//  Store.m
//  Repunch
//
//  Created by Emil on 9/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RPStore.h"
#import <Parse/PFObject+Subclass.h>

@interface RPStore()

@end

@implementation RPStore

#pragma mark - properties synthesize

@synthesize avatar;
@synthesize hoursManager;
@synthesize m_storeHoursManager;

@dynamic active;
@dynamic rewards;
@dynamic hours;
@dynamic categories;
@dynamic store_name;
@dynamic street;
@dynamic cross_streets;
@dynamic neighborhood;
@dynamic state;
@dynamic city;
@dynamic zip;
@dynamic phone_number;
@dynamic store_avatar;
@dynamic punches_facebook;
@dynamic coordinates;

#pragma mark - Parse

+ (NSString *)parseClassName
{
    return @"Store";
}

#pragma mark - Update Store

- (void)updateStoreInfoWithCompletionHandler:(StoreUpdateHandler)handler
{
    __weak typeof (self) weakSelf = self;
    
    [self refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            weakSelf.m_storeHoursManager = nil;
            BLOCK_SAFE_RUN(handler, weakSelf, kRPErrorNone);
        }
        else {
            RPErrorCode errorCode = ([error code] == kPFErrorConnectionFailed) ? kRPErrorNetworkConnection : kRPErrorDidFailUnknown;
            BLOCK_SAFE_RUN(handler, weakSelf, errorCode);
        }
    }];
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

- (NSString *)formattedAddress
{
    NSString *street = self.street;
    
    if( !IS_NIL(self.cross_streets) ) {
        street = [[street stringByAppendingString:@"\n"] stringByAppendingString:self.cross_streets];
	}
    
    if( !IS_NIL(self.neighborhood) ) {
        street = [[street stringByAppendingString:@"\n"] stringByAppendingString:self.neighborhood];
	}
    
    street = [street stringByAppendingString:[NSString stringWithFormat:@"\n%@, %@ %@", self.city, self.state, self.zip]];
    
    return street;
}

- (RPStoreHours *)hoursManager
{
    if (!m_storeHoursManager) {
        m_storeHoursManager = [[RPStoreHours alloc] initWithStoreHoursArray:self.hours];
    }
    return m_storeHoursManager;
}

@end
