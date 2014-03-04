//
//  DataManager.h
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "RPInstallation.h"
#import "RPUser.h"
#import "RPPatron.h"
#import "RPPatronStore.h"
#import "RPStore.h"
#import "RPStoreLocation.h"
#import "RPMessage.h"
#import "RPMessageStatus.h"
#import "RPFacebookPost.h"

@interface DataManager : NSObject

+ (DataManager *) getSharedInstance;

@property (strong, atomic) RPPatron *patron;

// TODO: change some of these to NSCache for out-of-memory scenarios
@property (strong, atomic) NSMutableDictionary *patronStores;
@property (strong, atomic) NSMutableDictionary *stores;
@property (strong, atomic) NSMutableDictionary *storeLocations;
@property (strong, atomic) NSMutableDictionary *messageStatuses;
@property (strong, atomic) NSCache *storeThumbnailImageCache;
@property (strong, atomic) NSCache *storeCoverImageCache;

- (void) clearData;

// PatronStore methods
- (NSDictionary*) getAllPatronStores;
- (RPPatronStore *)getPatronStore:(NSString *)storeId;
- (void)addPatronStore:(RPPatronStore *)patronStore forKey:(NSString *)storeId;
- (void)deletePatronStore:(NSString *)storeId;
- (void)updatePatronStorePunchCount:(NSString *)storeId withPunches:(NSInteger)punches;
//- (void)updatePatronStoreAllTimePunchCount:(NSString *)storeId withPunches:(NSInteger)punches;

// Assumptions:
// StoreLocation->Store will always be null
// Store -> StoreLocation will always work

// Store methods
- (void)addStore:(RPStore *)store;
- (RPStore *)getStore:(NSString *)objectId;

// StoreLocation methods
- (RPStoreLocation *)getStoreLocation:(NSString *)objectId;

// Store image methods
- (void)addThumbnailImage:(UIImage *)image forKey:(NSString *)storeId;
- (UIImage *)getThumbnailImage:(NSString *)storeId;
- (void)addCoverImage:(UIImage *)image forKey:(NSString *)storeId;
- (UIImage *)getCoverImage:(NSString *)storeId;

// MessageStatus/Message methods
- (void)addMessage:(RPMessageStatus *)messageStatus;
- (RPMessageStatus *)getMessage:(NSString *)objectId;
- (void)removeMessage:(NSString *)objectId;

@end
