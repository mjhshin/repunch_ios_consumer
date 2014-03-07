//
//  LocationManager.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//
#import "LocationManager.h"

#define DISTANCE_FILTER 5.0
#define RECENT_INTERVAL 10.0
#define TIMEOUT_INTERVAL 10.0

@interface LocationManager() <CLLocationManagerDelegate> {
	CLLocation *location;
	NSTimer *timeoutTimer;
}

@property (strong, nonatomic, readonly) CLLocationManager *locationManager;
@property (copy, nonatomic) LocationManagerLocationUpdateBlock locationBlock;

@end

@implementation LocationManager

static LocationManager *sharedLocationManager = nil;    // static instance variable

+ (LocationManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[LocationManager alloc] init];
    });
    return sharedLocationManager;
}

- (id)init
{
	NSLog(@"LM alloc");
	if (self = [super init])
	{
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = DISTANCE_FILTER; //filter out negligible changes in distance
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"LM dealloc");
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
										   target:self
										 selector:@selector(locationUpdateTimeout)
										 userInfo:nil
										  repeats:NO];
	
	[_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
	[_locationManager stopUpdatingLocation];
	
	if(timeoutTimer != nil) {
		if([timeoutTimer isValid]) {
			[timeoutTimer invalidate];
		}
		timeoutTimer = nil;
	}
}

- (void)locationUpdateTimeout
{
	[self stopUpdatingLocation];
	
	//TODO: create timeout error and send back to block
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* newLocation = [locations lastObject];
	NSDate* eventDate = newLocation.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
	NSLog(@"LM didUpdateLocations: lat: %f, lng: %f, timestamp: %@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, eventDate);
	
	if(abs(howRecent) > RECENT_INTERVAL) {
		NSLog(@"LocationManager didUpdateToLocation with timestamp %@ which is too old to use.", newLocation.timestamp);
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