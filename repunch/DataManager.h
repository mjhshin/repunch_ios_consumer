//
//  DataManager.h
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "RPPatron.h"
#import "RPPatronStore.h"
#import "RPStore.h"
#import "RPStoreLocation.h"

@interface DataManager : NSObject

+ (DataManager *) getSharedInstance;

@property (strong, atomic) RPPatron *patron;

// TODO: change some of these to NSCache for out-of-memory scenarios
@property (strong, atomic) NSMutableDictionary *patronStores;
@property (strong, atomic) NSMutableDictionary *stores;
@property (strong, atomic) NSMutableDictionary *storeLocations;
@property (strong, atomic) NSMutableDictionary *messageStatuses;
@property (strong, atomic) NSCache *storeImageCache;

- (void) clearData;

// PatronStore methods
- (NSDictionary*) getAllPatronStores;
- (RPPatronStore *)getPatronStore:(NSString *)storeId;
- (void)addPatronStore:(RPPatronStore *)patronStore forKey:(NSString *)storeId;
- (void)deletePatronStore:(NSString *)storeId;
- (void)updatePatronStore:(NSString *)storeId withPunches:(int)punches;

// Store methods
- (void)addStore:(RPStore *)store;
- (RPStore *)getStore:(NSString *)objectId;

// Store methods
- (void)addStoreLocation:(RPStoreLocation *)storeLocation;
- (RPStoreLocation *)getStoreLocation:(NSString *)objectId;

// Store image cache methods
- (void)addStoreImage:(UIImage *)image forKey:(NSString *)storeId;
- (UIImage *)getStoreImage:(NSString *)storeId;

// MessageStatus/Message methods
- (void)addMessage:(PFObject *)messageStatus;
- (PFObject *)getMessage:(NSString *)objectId;
- (void)removeMessage:(NSString *)objectId;

@end
