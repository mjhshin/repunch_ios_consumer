//
//  CoreDataStore.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStore : NSObject
-(void)deleteAll;
-(void)deleteDataForObject:(NSString *)entityName;
+(void)printDataForObject:(NSString *)entityName;
+(void)saveContext;
@end
