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

- (void)addStore:(PFObject *)store forKey:(NSString *)objectId
{
	[_stores setObject:store forKey:objectId];
}

- (PFObject *)getStore:(NSString *)objectId
{
	return [_stores objectForKey:objectId];
}

@end