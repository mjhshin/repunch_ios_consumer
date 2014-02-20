//
//  LocationViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/30/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "LocationsViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController {
	CLLocationCoordinate2D coordinates;
	NSString *storeName;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	
	[self setInformation];
	[self addMapAnnotation];
}

- (void)setInformation
{
	RPStore *store = [[DataManager getSharedInstance] getStore:self.storeLocation.Store.objectId];
	storeName = store.store_name;
	self.navigationItem.title = storeName;
	
	self.mapButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	[self.mapButton setTitle:self.storeLocation.formattedAddress forState:UIControlStateNormal];
	[self.callButton setTitle:self.storeLocation.phone_number forState:UIControlStateNormal];

	self.otherLocationsButton.hidden = (store.store_locations.count <= 1);
	self.bottomDivider.hidden = (store.store_locations.count <= 1);
}

- (void)addMapAnnotation
{
	coordinates = CLLocationCoordinate2DMake(self.storeLocation.coordinates.latitude,
											 self.storeLocation.coordinates.longitude);
	
	[self.mapView setCenterCoordinate:coordinates
							zoomLevel:15
							 animated:NO];
	
	
    MapPin *placePin = [[MapPin alloc] initWithCoordinates:coordinates
												 placeName:storeName
											   description:self.storeLocation.street];
	//placePin.can
    
    [self.mapView addAnnotation:placePin];
}

- (void)expandMapView //TODO: slide animation for these changes
{
	self.scrollView.contentOffset = CGPointZero;
	
	self.mapViewHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height + 44.0f;
	[self.navigationController setNavigationBarHidden:YES];
	
	self.tapGestureRecognizer.enabled = NO;
	self.mapView.zoomEnabled = YES;
	self.mapView.scrollEnabled = YES;
	
	self.expandedMapExitButton.hidden = NO;
	self.expandedMapDirectionsButton.hidden = NO;
	self.expandedMapStatusBar.hidden = NO;
}

- (void)shrinkMapView
{
	self.mapViewHeightConstraint.constant = 300.0f;
	[self.navigationController setNavigationBarHidden:NO];
	
	self.tapGestureRecognizer.enabled = YES;
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	
	self.expandedMapExitButton.hidden = YES;
	self.expandedMapDirectionsButton.hidden = YES;
	self.expandedMapStatusBar.hidden = YES;
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

- (IBAction)bigMapExitButtonAction:(id)sender
{
	[self shrinkMapView];
}

- (IBAction)bigMapDirectionsButtonAction:(id)sender
{
	[self getDirections];
}

- (IBAction)mapButtonAction:(id)sender
{
	[self getDirections];
}

- (IBAction)callButtonAction:(id)sender
{	
	NSString *urlString = [@"tel://" stringByAppendingString:self.storeLocation.phone_number];
	NSURL *url = [NSURL URLWithString:urlString];
	
	if( [[UIApplication sharedApplication] canOpenURL:url] ) {
		[[UIApplication sharedApplication] openURL:url];
	}
	else {
		[RepunchUtils showDialogWithTitle:@"This device does not support phone calls" withMessage:nil];
	}
}

- (IBAction)otherLocationsButtonAction:(id)sender
{
	LocationsViewController *locationsVC = [[LocationsViewController alloc] init];
	locationsVC.storeId = self.storeLocation.Store.objectId;
	[self.navigationController pushViewController:locationsVC animated:YES];
}

- (IBAction)mapTapGestureAction:(UITapGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded)
	{
        [self expandMapView];
    }
}

@end
