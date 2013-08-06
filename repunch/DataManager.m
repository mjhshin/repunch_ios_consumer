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
        self.storeImageCache = [[NSCache alloc] init];
        self.messageStatuses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

// PatronStore methods
- (NSDictionary*) getAllPatronStores
{
	return self.patronStores;
}

- (NSInteger) getPatronStoreCount
{
	return [self.patronStores count];
}

- (void)addPatronStore:(PFObject *)patronStore forKey:(NSString *)objectId
{
    [self.patronStores setObject:patronStore forKey:objectId];
}

- (PFObject *)getPatronStore:(NSString *)objectId
{
	return [self.patronStores objectForKey:objectId];
}

// Store methods
- (void)addStore:(PFObject *)store
{
	[self.stores setObject:store forKey:[store objectId]];
}

- (PFObject *)getStore:(NSString *)objectId
{
	return [self.stores objectForKey:objectId];
}

// Store image cache methods
- (void)addStoreImage:(UIImage *)image forKey:(NSString *)storeId
{
    [self.storeImageCache setObject:image forKey:storeId];
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

@end