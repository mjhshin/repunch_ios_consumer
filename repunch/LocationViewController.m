//
//  LocationViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/30/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController {
	UITapGestureRecognizer *tapGestureRecognizer;
	CLLocationCoordinate2D coordinates;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationItem.title = @"Store Name";
	
	// Make header selectable
	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																   action:@selector(handleTapGesture:)];
	[tapGestureRecognizer setDelegate:self];
	tapGestureRecognizer.numberOfTouchesRequired = 1;
	tapGestureRecognizer.numberOfTapsRequired = 1;
	[self.mapView addGestureRecognizer:tapGestureRecognizer];
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	
	[self setInformation];
	[self addMapAnnotation];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
	{
        [self expandMapView];
    }
}

- (void)setInformation
{
	
}

- (void)addMapAnnotation
{
	coordinates = CLLocationCoordinate2DMake(self.storeLocation.coordinates.latitude,
											 self.storeLocation.coordinates.longitude);
	
	[self.mapView setCenterCoordinate:coordinates
							zoomLevel:14
							 animated:NO];
	
	
    MapPin *placePin = [[MapPin alloc] initWithCoordinates:coordinates
												 placeName:@"BLA"//self.storeLocation.Store.store_name
											   description:self.storeLocation.formattedAddress];
    
    [self.mapView addAnnotation:placePin];
}

- (void)expandMapView
{
	self.mapViewHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	tapGestureRecognizer.enabled = NO;
	self.mapView.zoomEnabled = YES;
	self.mapView.scrollEnabled = YES;
	
	self.bigMapExitButton.hidden = NO;
	self.bigMapDirectionsButton.hidden = NO;
	
	self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void)shrinkMapView
{
	self.mapViewHeightConstraint.constant = 300.0f;
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	tapGestureRecognizer.enabled = YES;
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	
	self.bigMapExitButton.hidden = YES;
	self.bigMapDirectionsButton.hidden = YES;
	
	self.scrollView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
}

- (void)getDirections
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates
                                                       addressDictionary:nil];
		
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = @"BLA";//self.storeLocation.Store.store_name;
        
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
	
}

@end
