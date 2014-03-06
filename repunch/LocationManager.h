//
//  LocationManager.h
//  RepunchConsumer
//
//  Created by Michael Shin on 3/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef void (^LocationManagerLocationUpdateBlock)(CLLocationManager *manager, CLLocation *location, NSError *error);

@interface LocationManager : NSObject

+ (LocationManager *)getSharedInstance;
+ (BOOL)locationServicesEnabled;

- (CLLocation *)location;
- (void)startUpdatingLocationWithBlock:(LocationManagerLocationUpdateBlock)block;
- (void)stopUpdatingLocation;

@end
