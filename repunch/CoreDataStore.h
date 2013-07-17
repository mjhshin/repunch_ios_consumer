//
//  CoreDataStore.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStore : NSObject
<<<<<<< HEAD
-(void)deleteAll;
-(void)deleteDataForObject:(NSString *)entityName;
=======
+(void)deleteAll;
+(void)deleteDataForObject:(NSString *)entityName;
>>>>>>> 080289920eb904c090957c1a9738892947996bd5
+(void)printDataForObject:(NSString *)entityName;
+(void)saveContext;
@end
