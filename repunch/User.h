//
//  User.h
//  repunch
//
//  Created by Gwendolyn Weston on 6/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSManagedObject *patron;

-(void) setFromParse:(PFUser *)user;

@end
