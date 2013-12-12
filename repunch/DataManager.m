//
//  DataManager.m
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager *sharedDataManager = nil;    // static instance variable

+ (DataManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[DataManager alloc] init];
    });
    return sharedDataManager;
}

- (id) init
{
	if (self = [super init])
	{
        self.patronStores = [[NSMutableDictionary alloc] init];
        self.stores = [[NSMutableDictionary alloc] init];
		self.storeLocations = [[NSMutableDictionary alloc] init];
        self.storeImageCache = [[NSCache alloc] init];
        self.messageStatuses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)clearData
{
	[self.patronStores removeAllObjects];
	[self.stores removeAllObjects];
	[self.storeLocations removeAllObjects];
	[self.messageStatuses removeAllObjects];
}

// PatronStore methods
- (NSDictionary*) getAllPatronStores
{
	return self.patronStores;
}

- (PFObject *)getPatronStore:(NSString *)storeId
{
	return [self.patronStores objectForKey:storeId];
}

- (void)addPatronStore:(PFObject *)patronStore forKey:(NSString *)storeId
{
    [self.patronStores setObject:patronStore forKey:storeId];
}

- (void) deletePatronStore:(NSString *)storeId
{
	[self.patronStores removeObjectForKey:storeId];
}

- (void)updatePatronStore:(NSString *)storeId withPunches:(int)punches
{
	[[self.patronStores objectForKey:storeId] setObject:[NSNumber numberWithInt:punches] forKey:@"punch_count"];
}

// Store methods
- (void)addStore:(RPStore *)store
{
	[self.stores setObject:store forKey:store.objectId];
}

- (RPStore *)getStore:(NSString *)objectId
{
	return [self.stores objectForKey:objectId];
}

// StoreLocation methods
- (void)addStoreLocation:(RPStoreLocation *)storeLocation
{
	[self.storeLocations setObject:storeLocation forKey:storeLocation.objectId];
}

- (RPStoreLocation *)getStoreLocation:(NSString *)objectId
{
	return [self.storeLocations objectForKey:objectId];
}

// Store image cache methods
- (void)addStoreImage:(UIImage *)image forKey:(NSString *)storeId
{
	if(image != nil) {
		[self.storeImageCache setObject:image forKey:storeId];
	}
}

- (UIImage *)getStoreImage:(NSString *)storeId
{
    return [self.storeImageCache objectForKey:storeId];
}

// MessageStatus/Message methods
- (void)addMessage:(PFObject *)messageStatus
{
    [self.messageStatuses setObject:messageStatus forKey:[messageStatus objectId]];
}

- (PFObject *)getMessage:(NSString *)objectId
{
    return [self.messageStatuses objectForKey:objectId];
}

- (void)removeMessage:(NSString *)objectId
{
	PFObject *msgStatus = [self.messageStatuses objectForKey:objectId];
	[self.messageStatuses removeObjectForKey:objectId];
	
    PFRelation *relation = [self.patron relationforKey:@"ReceivedMessages"];
	[relation removeObject:msgStatus];
	[self.patron saveInBackground];
}

@end