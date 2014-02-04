//
//  LocationViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/30/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController {
	UITapGestureRecognizer *tapGestureRecognizer;
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
	RPStore *store = [[DataManager getSharedInstance] getStore:self.storeLocation.Store.objectId];
	storeName = store.store_name;
	self.navigationItem.title = storeName;
	
	self.mapButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	[self.mapButton setTitle:self.storeLocation.formattedAddress forState:UIControlStateNormal];
	[self.callButton setTitle:self.storeLocation.phone_number forState:UIControlStateNormal];
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
	
	tapGestureRecognizer.enabled = NO;
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
	
	tapGestureRecognizer.enabled = YES;
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
	NSString *phoneNumber
		= [self.storeLocation.phone_number stringByReplacingOccurrencesOfString:@"[^0-9]"
																	 withString:@""
																		options:NSRegularExpressionSearch
																		  range:NSMakeRange(0, self.storeLocation.phone_number.length)];
	
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];
}

@end
