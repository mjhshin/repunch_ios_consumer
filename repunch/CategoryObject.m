//
//  CategoryObject.m
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "CategoryObject.h"
#import "Retailer.h"


@implementation CategoryObject

@dynamic name;
@dynamic alias;
@dynamic places;

- (void) setFromParse:(id)category
{
    self.name = [category objectForKey:@"name"];
    self.alias = [category objectForKey:@"alias"];
}

@end
