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
	if (self = [super init]) {
		_patronStores = [[NSMutableDictionary alloc] init];
		_stores = [[NSMutableDictionary alloc] init];
		_messageStatuses = [[NSMutableDictionary alloc] init];
	}
	return self;
}

//PatronStore methods
- (NSDictionary*) getAllPatronStores
{
	return _patronStores;
}

- (NSInteger) getPatronStoreCount
{
	return [_patronStores count];
}

- (void)addPatronStore:(PFObject *)patronStore forKey:(NSString *)objectId
{
    [_patronStores setObject:patronStore forKey:objectId];
}

- (PFObject *)getPatronStore:(NSString *)objectId
{
	return [_patronStores objectForKey:objectId];
}

//Store methods
- (void)addStore:(PFObject *)store
{
	[_stores setObject:store forKey:[store objectId]];
}

- (PFObject *)getStore:(NSString *)objectId
{
	return [_stores objectForKey:objectId];
}

//MessageStatus/Message methods
- (void)addMessage:(PFObject *)messageStatus
{
    [_messageStatuses setObject:messageStatus forKey:[messageStatus objectId]];
}

- (PFObject *)getMessage:(NSString *)objectId
{
    return [_messageStatuses objectForKey:objectId];
}

@end