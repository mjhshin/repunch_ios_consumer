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
        self.storeThumbnailImageCache = [[NSCache alloc] init];
		self.storeCoverImageCache = [[NSCache alloc] init];
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

- (RPPatronStore *)getPatronStore:(NSString *)storeId
{
	return [self.patronStores objectForKey:storeId];
}

- (void)addPatronStore:(RPPatronStore *)patronStore forKey:(NSString *)storeId
{
    [self.patronStores setObject:patronStore forKey:storeId];
}

- (void)deletePatronStore:(NSString *)storeId
{
	[self.patronStores removeObjectForKey:storeId];
}

- (void)updatePatronStore:(NSString *)storeId withPunches:(NSInteger)punches
{
	[[self.patronStores objectForKey:storeId] setObject:[NSNumber numberWithInteger:punches]
												 forKey:@"punch_count"];
}

/*
- (void)updatePatronStoreAllTimePunchCount:(NSString *)storeId withPunches:(NSInteger)punches
{
	RPPatronStore *patronStore = [self.patronStores objectForKey:storeId];
	
	//if(patronStore.all
}
*/

// Store methods
- (void)addStore:(RPStore *)store
{
	[self.stores setObject:store forKey:store.objectId];
	
	for(RPStoreLocation *location in store.store_locations) {
		[self.storeLocations setObject:location forKey:location.objectId];
	}
}

- (RPStore *)getStore:(NSString *)objectId
{
	return [self.stores objectForKey:objectId];
}

// StoreLocation methods
- (RPStoreLocation *)getStoreLocation:(NSString *)objectId
{
	return [self.storeLocations objectForKey:objectId];
}

// Store image methods
- (void)addThumbnailImage:(UIImage *)image forKey:(NSString *)storeId
{
	[self.storeThumbnailImageCache setObject:image forKey:storeId];
}

- (UIImage *)getThumbnailImage:(NSString *)storeId
{
	return [self.storeThumbnailImageCache objectForKey:storeId];
}

- (void)addCoverImage:(UIImage *)image forKey:(NSString *)storeId
{
	[self.storeCoverImageCache setObject:image forKey:storeId];
}

- (UIImage *)getCoverImage:(NSString *)storeId
{
	return [self.storeCoverImageCache objectForKey:storeId];
}

// MessageStatus/Message methods
- (void)addMessage:(RPMessageStatus *)messageStatus
{
    [self.messageStatuses setObject:messageStatus forKey:messageStatus.objectId];
}

- (RPMessageStatus *)getMessage:(NSString *)objectId
{
    return [self.messageStatuses objectForKey:objectId];
}

- (void)removeMessage:(NSString *)objectId
{
	RPMessageStatus *messageStatus = [self.messageStatuses objectForKey:objectId];
	[self.messageStatuses removeObjectForKey:objectId];
	
    PFRelation *relation = [self.patron relationforKey:@"ReceivedMessages"];
	[relation removeObject:messageStatus];
	[self.patron saveInBackground];
}

@end