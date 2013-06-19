//
//  Category.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "Category.h"
#import "Store.h"


@implementation Category

@dynamic alias;
@dynamic name;
@dynamic store;

- (void) setFromParse:(id)category
{
    self.name = [category objectForKey:@"name"];
    self.alias = [category objectForKey:@"alias"];
}

@end
