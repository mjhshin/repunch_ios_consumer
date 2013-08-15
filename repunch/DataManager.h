//
//  DataManager.h
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DataManager : NSObject

+ (DataManager *) getSharedInstance;

// TODO: change some of these to NSCache for out-of-memory scenarios
@property (strong, atomic) NSMutableDictionary *patronStores;
@property (strong, atomic) NSMutableDictionary *stores;
@property (strong, atomic) NSMutableDictionary *messageStatuses;
//@property (strong, atomic) NSMutableDictionary *messages;
@property (strong, atomic) NSCache *storeImageCache;
@property (strong, atomic) PFObject *patron;

- (void) clearData;

// PatronStore methods
- (NSDictionary*) getAllPatronStores;
- (PFObject *)getPatronStore:(NSString *)storeId;
- (void)addPatronStore:(PFObject *)patronStore forKey:(NSString *)storeId;
- (void)deletePatronStore:(NSString *)storeId;
- (void)updatePatronStore:(NSString *)storeId withPunches:(int)punches;

// Store methods
- (void)addStore:(PFObject *)store;
- (PFObject *)getStore:(NSString *)objectId;

// Store image cache methods
- (void)addStoreImage:(UIImage *)image forKey:(NSString *)storeId;
- (UIImage *)getStoreImage:(NSString *)storeId;

// MessageStatus/Message methods
- (void)addMessage:(PFObject *)messageStatus;
- (PFObject *)getMessage:(NSString *)objectId;
- (void)removeMessage:(NSString *)objectId;

@end