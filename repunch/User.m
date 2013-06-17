//
//  User.m
//  repunch
//
//  Created by Gwendolyn Weston on 6/16/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "User.h"



@implementation User

@dynamic email;
@dynamic password;
@dynamic username;
@dynamic patron;


-(void) setFromParse:(PFUser *)user
{
    self.username = user.username;
    self.email = user.email;
}

/* QUESTION What is this function for?!
-(BOOL) hasPlace:(Retailer *)place
{
    for (Retailer *thisPlace in self.my_places){
        if ([thisPlace.retailer_id isEqualToString:place.retailer_id]) {
            return YES;
        }
    }
    
    return NO;
}
 */

@end
