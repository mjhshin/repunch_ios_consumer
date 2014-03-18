//
//  RPAnnotation.h
//  RepunchConsumer
//
//  Created by Michael Shin on 3/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RPAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *storeLocationId;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
				placeName:(NSString *)placeName
			  description:(NSString *)description
		  storeLocationId:(NSString *)storeLocationId;

@end