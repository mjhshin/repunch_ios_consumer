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
	RPStore *store;
	RPStoreLocation *storeLocation;
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
	storeLocation = [[DataManager getSharedInstance] getStoreLocation:self.storeLocationId];
	store = [[DataManager getSharedInstance] getStore:storeLocation.Store.objectId];
	self.navigationItem.title = store.store_name;
	
	self.mapButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	[self.mapButton setTitle:storeLocation.formattedAddress forState:UIControlStateNormal];
	[self.callButton setTitle:storeLocation.phone_number forState:UIControlStateNormal];

	// TODO: add this feature
	self.otherLocationsButton.hidden = YES;//(store.store_locations.count <= 1);
	self.bottomDivider.hidden = YES;//(store.store_locations.count <= 1);
	
	[self setStoreHours];
}

- (void)setStoreHours
{
	if(storeLocation.hours.count == 0) {
		self.hoursView.hidden = YES;
		return;
	}
	else if([storeLocation.hours lastObject][@"day"] == 0) {
		self.daysLabel.text = @"Open 24/7";
		return;
	}
	
	NSArray *days = [NSArray arrayWithObjects: @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
	NSMutableAttributedString *dayString = [[NSMutableAttributedString alloc] init];
	NSMutableAttributedString *hourString = [[NSMutableAttributedString alloc] init];
	
	for(int day = 1; day <= 7; day++)
	{
		BOOL found = NO;
		for(id entry in storeLocation.hours)
		{
			if([entry[@"day"] intValue] == day) {
				if(!found) {
					[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:days[day - 1]]];
					[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:entry[@"open_time"]]];
				} else {
					[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
					[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:days[day - 1]]];
				}
				found = YES;
			}
		}
	}
	
}

- (void)addMapAnnotation
{
	coordinates = CLLocationCoordinate2DMake(storeLocation.coordinates.latitude,
											 storeLocation.coordinates.longitude);
	
	[self.mapView setCenterCoordinate:coordinates
							zoomLevel:15
							 animated:NO];
	
	
    MapPin *placePin = [[MapPin alloc] initWithCoordinates:coordinates
												 placeName:store.store_name
											   description:storeLocation.street];
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
	NSString *urlString = [@"tel://" stringByAppendingString:storeLocation.phone_number];
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
	locationsVC.storeId = store.objectId;
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
