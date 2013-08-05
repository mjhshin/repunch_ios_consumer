//
//  SharedData.m
//  RepunchConsumer
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

static SharedData *sharedDataInstance = nil;    // static instance variable

+ (SharedData *)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataInstance = [[SharedData alloc] init];
		
		//init data structures
    });
    return sharedDataInstance;
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