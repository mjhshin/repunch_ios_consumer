//
//  Store.m
//  Repunch
//
//  Created by Emil on 9/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RPStore.h"
#import <Parse/PFObject+Subclass.h>

#import "NSDate+Additions.h"
#import "RPStoreHours.h"

NSString * const kStoreDidUpdateTotalPendingCount = @"kStoreDidUpdatePendingCount";

@interface RPStore (){
    
}

@property (strong, atomic) RPStoreHours *m_storeHoursManager;
@property (strong, readonly, atomic) PFRelation *RedeemRewards;
@property (strong, readonly, atomic) PFFile *store_avatar;
@property (strong, readonly, atomic) NSString *street;
@property (strong, readonly, atomic) NSString *cross_streets;
@property (strong, readonly, atomic) NSString *neighborhood;
@property (strong, readonly, atomic) NSString *state;
@property (strong, readonly, atomic) NSString *city;
@property (strong, readonly, atomic) NSString *zip;


@end

@implementation RPStore

#pragma mark - properties synthesize
@synthesize avatar;
@synthesize hoursManager;
@synthesize m_storeHoursManager;

@dynamic RedeemRewards;
@dynamic active;
@dynamic store_avatar;

@dynamic rewards;
@dynamic hours;
@dynamic store_name;

@dynamic street;
@dynamic cross_streets;
@dynamic neighborhood;
@dynamic state;
@dynamic city;
@dynamic zip;

#pragma mark - Fetching

#pragma mark - update store

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

- (void)updateStoreAvatarWithCompletionHander:(StoreUpdateAvatarHandler)handler
{
    if (!self.isDataAvailable) { // store has data not available
        BLOCK_SAFE_RUN(handler, self, nil, kRPErrorDidFailUnknown);
        return;
    }
    else if (IS_NIL( self.store_avatar)){ // avatar is not availible on server
        BLOCK_SAFE_RUN(handler, self, nil, kRPErrorStoreAvatarIsNotAvailibleOnServer);
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [self.store_avatar getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            avatar = [UIImage imageWithData:data];
            BLOCK_SAFE_RUN(handler, weakSelf, weakSelf.avatar, kRPErrorNone);
        }
        else {
            RPErrorCode errorCode = ([error code] == kPFErrorConnectionFailed) ? kRPErrorNetworkConnection : kRPErrorDidFailUnknown;
            BLOCK_SAFE_RUN(handler, weakSelf, weakSelf.avatar, errorCode);
        }
    }];
}


- (NSString *)address
{
    NSString *street = self.street;
    
    if(!IS_NIL( self.cross_streets))
        street = [[street stringByAppendingString:@"\n"] stringByAppendingString:self.cross_streets];
    
    if(!IS_NIL( self.neighborhood))
        street = [[street stringByAppendingString:@"\n"] stringByAppendingString:self.neighborhood];
    
    street = [street stringByAppendingString:@"\n"];
    street = [street stringByAppendingString:[NSString stringWithFormat:@"%@, %@ %@", self.city, self.state, self.zip]];
    
    return street;
}

- (RPStoreHours *)hoursManager
{
    if (!m_storeHoursManager) {
        m_storeHoursManager = [[RPStoreHours alloc] initWithStoreHoursArray:self.hours];
    }
    return m_storeHoursManager;
}

#pragma mark - Parse
+ (NSString *)parseClassName
{
    return @"Store";
}

+ (PFQuery *)query
{
    PFQuery * query = [PFQuery queryWithClassName:[self parseClassName]];
    [query includeKey:@"Settings"];
    return query;
}

@end
