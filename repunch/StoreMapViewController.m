//
//  PlacesDetailMapViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreMapViewController.h"

@implementation StoreMapViewController
{
	PFObject *store;
	PFGeoPoint *coordinates;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_exit.png"]
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(closeView:)];
	
	UIBarButtonItem *directionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions"
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(getDirections:)];
	self.navigationItem.leftBarButtonItem = exitButton;
	self.navigationItem.rightBarButtonItem = directionsButton;
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    MKMapView *placeMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - navBarHeight)];
	
	DataManager *sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	coordinates = [store objectForKey:@"coordinates"];
    
	[placeMapView setCenterCoordinate:CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude) zoomLevel:14 animated:NO];
    
    NSString *address = [NSString stringWithFormat:@"%@\n%@, %@ %@", [store objectForKey:@"street"], [store objectForKey:@"city"], [store objectForKey:@"state"], [store objectForKey:@"zip"]];

    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude)
												 placeName:[store objectForKey:@"store_name"]
											   description:address];
    
    [placeMapView addAnnotation:placePin];
    
    [self.view addSubview:placeMapView];
}

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getDirections:(id)sender
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {        
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude);
        
		MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
		
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = [store objectForKey:@"store_name"];
        
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
	[RepunchUtils showNavigationBarDropdownView:self.view];
}

@end
