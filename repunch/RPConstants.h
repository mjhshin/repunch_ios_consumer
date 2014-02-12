//
//  RPConstants.h
//  RepunchConsumer
//
//  Created by Michael Shin on 10/25/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#ifndef RepunchConsumer_RPConstants_h
#define RepunchConsumer_RPConstants_h

#define IS_NIL(x) ([x isKindOfClass:[NSNull class]] || x == nil)

#define LOG(x) (NSLog(x); CLS_LOG(x);)

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

typedef void(^AuthenticationManagerHandler)(NSInteger errorCode);

typedef void(^MyPlacesFetchHandler)(NSArray *results, NSError *error);
typedef void(^InboxFetchHandler)(NSArray *results, NSError *error);
typedef void(^SearchResultHandler)(NSArray *results, NSError *error);

typedef enum {
    // General
    kRPErrorNone,
    kRPErrorDidFailUnknown,
    kRPErrorNetworkConnection,
    kRPErrorStoreAvatarIsNotAvailibleOnServer,
    
} RPErrorCode;


@class RPStore;

//typedef void(^StoreUpdateHandler)(RPStore *store, RPErrorCode errorCode);
typedef void(^StoreImageUpdateHandler)(UIImage *image, NSError *error);

@class RPStoreLocation;

//typedef void(^StoreLocationUpdateHandler)(RPStoreLocation *store, RPErrorCode errorCode);
typedef void(^StoreLocationImageUpdateHandler)(UIImage *image, NSError *error);

#endif
                                                                            