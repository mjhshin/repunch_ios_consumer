//
//  PlacesDetailMapViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreMapViewController.h"

@implementation StoreMapViewController
{
	RPStore *store;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				target:self
																				action:@selector(closeView)];
	
	UIBarButtonItem *directionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(getDirections)];
	self.navigationItem.leftBarButtonItem = exitButton;
	self.navigationItem.rightBarButtonItem = directionsButton;
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    MKMapView *placeMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - navBarHeight)];
	
	DataManager *sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
    /*
	[placeMapView setCenterCoordinate:CLLocationCoordinate2DMake(store.coordinates.latitude, store.coordinates.longitude) zoomLevel:14 animated:NO];

    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(store.coordinates.latitude, store.coordinates.longitude)
												 placeName:store.store_name
											   description:store.formattedAddress];
    
    [placeMapView addAnnotation:placePin];
    */
    [self.view addSubview:placeMapView];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getDirections
{/*
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(store.coordinates.latitude, store.coordinates.longitude)
                                                       addressDictionary:nil];
		
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = store.store_name;
        
        // Set the directions mode to "Driving"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
		
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
*/
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[RepunchUtils showDefaultDropdownView:self.view];
}

@end
