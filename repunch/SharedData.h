//
//  SharedData.h
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SharedData : NSObject

+ (SharedData *) init;

//TODO: change some of these to NSCache for out-of-memory scenarios
@property (strong, atomic) NSMutableDictionary *patronStores;
@property (strong, atomic) NSMutableDictionary *stores;
@property (strong, atomic) NSMutableDictionary *messageStatuses;
//@property (strong, atomic) NSMutableDictionary *messages;
@property (strong, atomic) NSCache *storeImageCache;
@property (strong, atomic) PFObject *patron;

//PatronStore methods
- (NSDictionary*) getAllPatronStores;
- (NSInteger) getPatronStoreCount;
- (void)addPatronStore:(PFObject *)patronStore forKey:(NSString *)objectId;
- (PFObject *)getPatronStore:(NSString *)objectId;

//Store methods
- (void)addStore:(PFObject *)store forKey:(NSString *)objectId;
- (PFObject *)getStore:(NSString *)objectId;

//MessageStatus/Message methods
- (void)addMessage:(PFObject *)messageStatus;
- (PFObject *)getMessage:(NSString *)objectId;

@end
