//
//  User.m
//  repunch
//
//  Created by CambioLabs on 4/15/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "User.h"
#import "Retailer.h"


@implementation User

@dynamic facebook_id;
@dynamic username;
@dynamic password;
@dynamic birth_date;
@dynamic email;
@dynamic gender;
@dynamic first_name;
@dynamic last_name;
@dynamic is_dirty;
@dynamic my_places;
@dynamic messages;

-(void) setFromParse:(PFUser *)user
{
    self.facebook_id = [user objectForKey:@"facebook_id"];
    self.username = user.username;
//    self.password = user.password;
    self.email = user.email;
    //            localUser.birth_date
    self.first_name = [user objectForKey:@"first_name"];
    self.last_name = [user objectForKey:@"last_name"];
    self.gender = [user objectForKey:@"gender"];
}

-(BOOL) hasPlace:(Retailer *)place
{
    for (Retailer *thisPlace in self.my_places){
        if ([thisPlace.retailer_id isEqualToString:place.retailer_id]) {
            return YES;
        }
    }
    
    return NO;
}

@end
