//
//  LocationManager.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//
#import "LocationManager.h"

#define DISTANCE_FILTER 5.0
#define TIMEOUT_INTERVAL 10.0

@interface LocationManager() <CLLocationManagerDelegate> {
	CLLocation *location;
	NSTimer *timeoutTimer;
}

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (strong, nonatomic) LocationManagerLocationUpdateBlock locationBlock;

@end

@implementation LocationManager

+ (LocationManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
	static LocationManager *sharedLocationManager = nil;    // static instance variable
	
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[LocationManager alloc] init];
    });
    return sharedLocationManager;
}

- (id) init
{
	if (self = [super init])
	{
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = DISTANCE_FILTER; //filter out negligible changes in distance
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	
	return self;
}

+ (BOOL)locationServicesEnabled
{
	return [CLLocationManager locationServicesEnabled];
}

- (CLLocation *)location
{
	return location;
}

- (void)startUpdatingLocationWithBlock:(LocationManagerLocationUpdateBlock)block
{
	self.locationBlock = block;
	
	timeoutTimer = [NSTimer timerWithTimeInterval:TIMEOUT_INTERVAL
										   target:_locationManager
										 selector:@selector(stopUpdatingLocation)
										 userInfo:nil
										  repeats:NO];
	
	[_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
	[_locationManager stopUpdatingLocation];
	
	if(timeoutTimer != nil) {
		[timeoutTimer invalidate];
	}
}

/*
- (void)locationUpdateTimeout
{
	[locationManager stopUpdatingLocation];
	
	if(timeoutTimer != nil) {
		[timeoutTimer invalidate];
	}
}
*/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* newLocation = [locations lastObject];
	NSDate* eventDate = newLocation.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
	if(howRecent > 8.0) {
		return;
	}
	
	location = newLocation;
	
	if(self.locationBlock != nil) {
		self.locationBlock(manager, location, nil);
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if(self.locationBlock != nil) {
		self.locationBlock(manager, nil, error);
	}
}

@end