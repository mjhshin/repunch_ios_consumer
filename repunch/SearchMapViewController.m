//
//  SearchMapViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/13/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "SearchMapViewController.h"
#import "DataManager.h"
#import "RPAnnotation.h"
#import "StoreViewController.h"
#import "RPAnnotationView.h"

#define MAX_LATITUDE 90.0
#define MAX_LONGITUDE 180.0

@interface SearchMapViewController ()

@end

@implementation SearchMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView.delegate = self;
}

- (void)refreshMapView
{
	[self.mapView removeAnnotations:self.mapView.annotations];
	
	double maxLongitude = -MAX_LONGITUDE;
	double minLongitude = MAX_LONGITUDE;
	double maxLatitude = -MAX_LATITUDE;
	double minLatitude = MAX_LATITUDE;
	
	NSMutableArray *annotationsArray = [NSMutableArray array];
	
	for(NSString *locationId in self.storeLocationIdArray)
	{
		RPStoreLocation *location = [[DataManager getSharedInstance] getStoreLocation:locationId];
		RPStore *store = [[DataManager getSharedInstance] getStore:location.Store.objectId];
		
		CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(location.coordinates.latitude,
																	   location.coordinates.longitude);
		
		RPAnnotation *pin = [[RPAnnotation alloc] initWithCoordinates:coordinates
															placeName:store.store_name
														  description:location.street
													  storeLocationId:locationId];
		
		[annotationsArray addObject:pin];
		
		maxLongitude = MAX(maxLongitude, coordinates.longitude);
		minLongitude = MIN(minLongitude, coordinates.longitude);
		maxLatitude = MAX(maxLatitude, coordinates.latitude);
		minLatitude = MIN(minLatitude, coordinates.latitude);
	}
	
	[self.mapView addAnnotations:annotationsArray];
	
	double avgLatitude = (maxLatitude + minLatitude)/2;
	double avgLongitude = (maxLongitude + minLongitude)/2;
	
	CLLocationCoordinate2D center = CLLocationCoordinate2DMake(avgLatitude, avgLongitude);
	
	//mutiply by 1.5 to cover 50% area past last pins (25% on each edges);
	double latitudeSpan = (maxLatitude - minLatitude)*1.5;
	double longitudeSpan = (maxLongitude - minLongitude) *1.5;
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	RPAnnotationView *pin = (RPAnnotationView *)
							[mapView dequeueReusableAnnotationViewWithIdentifier:[RPAnnotationView reuseIdentifier]];
	
	if(pin == nil) {
		pin = [[RPAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[RPAnnotationView reuseIdentifier]];
	}
	
	return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	RPAnnotation *annotation = (RPAnnotation *)view.annotation;
	RPStoreLocation *storeLocation = [[DataManager getSharedInstance] getStoreLocation:annotation.storeLocationId];
	StoreViewController *storeVC = [[StoreViewController alloc] init];
	storeVC.storeLocationId = storeLocation.objectId;
	storeVC.storeId = storeLocation.Store.objectId;
	[self.navigationController pushViewController:storeVC animated:YES];
}
/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if(![view.annotation isKindOfClass:[MKUserLocation class]])
    {
        CGSize  calloutSize = CGSizeMake(100.0, 80.0);
        UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-calloutSize.height, calloutSize.width, calloutSize.height)];
        calloutView.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(5.0, 5.0, calloutSize.width - 10.0, calloutSize.height - 10.0);
        [button setTitle:@"OK" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];
        [calloutView addSubview:button];
        [view.superview addSubview:calloutView];
    }
}*/

@end
