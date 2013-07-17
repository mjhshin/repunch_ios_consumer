//
//  CoreDataStore.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "CoreDataStore.h"

#import "Store.h"
#import "PatronStore.h"
#import "User.h"

@implementation CoreDataStore

#pragma mark - Cleaning Up
+(void)deleteDataForObject:(NSString *)entityName {
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *objects;
    
    if ([entityName isEqualToString:@"Store"]){
        objects = [Store MR_findAll];
    }
    
    if ([entityName isEqualToString:@"PatronStore"]){
        objects = [PatronStore MR_findAll];
    }
    
    
    if ([entityName isEqualToString:@"User"]){
        objects = [User MR_findAll];
    }
    
    
    for (id object in objects){
        [context deleteObject:object];
    }
        
    [CoreDataStore saveContext];
}

+(void)deleteAll {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *objects = [NSManagedObject MR_findAll];
    [context delete:objects];
    [CoreDataStore saveContext];
}
#pragma mark - Debugging

+(void)printDataForObject:(NSString *)entityName {
    
    NSArray *objects;
    
    if ([entityName isEqualToString:@"Store"]){
        objects = [Store MR_findAll];
    }
    if ([entityName isEqualToString:@"PatronStore"]){
        objects = [PatronStore MR_findAll];
    }
    if ([entityName isEqualToString:@"User"]){
        objects = [User MR_findAll];
    }
    
    NSLog(@"here are all the objects for entity: %@", entityName);
    for (id object in objects){
        if ([entityName isEqualToString:@"Store"]) NSLog(@"%@", [object valueForKey:@"store_name"]);
        if ([entityName isEqualToString:@"PatronStore"]) NSLog(@"%@", [[object valueForKey:@"store"] valueForKey:@"store_name"]);
        if ([entityName isEqualToString:@"User"]) NSLog(@"%@", [object valueForKey:@"username"]);
        
    }
}

<<<<<<< HEAD

#pragma mark - Get objects


=======
>>>>>>> 080289920eb904c090957c1a9738892947996bd5
+(void)saveContext {
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext MR_saveToPersistentStoreAndWait];
}



@end
