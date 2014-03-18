//
//  RPAnnotation.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPAnnotation.h"

@implementation RPAnnotation

@synthesize coordinate, title, subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
				placeName:(NSString *)placeName
			  description:(NSString *)description
		  storeLocationId:(NSString *)storeLocationId
{
    self = [super init];
	
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
		_storeLocationId = storeLocationId;
    }
    return self;
}

@end