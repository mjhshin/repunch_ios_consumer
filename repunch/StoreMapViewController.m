//
//  PlacesDetailMapViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreMapViewController.h"

@implementation StoreMapViewController {
	CLLocationCoordinate2D coordinates;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *directionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(getDirections)];
	self.navigationItem.rightBarButtonItem = directionsButton;
	self.navigationItem.title = @"";
	
	coordinates = CLLocationCoordinate2DMake(self.storeLocation.coordinates.latitude,
											 self.storeLocation.coordinates.longitude);

	[self.mapView setCenterCoordinate:coordinates
							zoomLevel:14
							 animated:NO];

    MapPin *placePin = [[MapPin alloc] initWithCoordinates:coordinates
												 placeName:self.storeLocation.Store.store_name
											   description:self.storeLocation.formattedAddress];
    
    [self.mapView addAnnotation:placePin];
}

- (void)getDirections
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates
                                                       addressDictionary:nil];
		
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.storeLocation.Store.store_name;
        
        // Set the directions mode to "Driving"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
		
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[RepunchUtils showDefaultDropdownView:self.view];
}

@end
