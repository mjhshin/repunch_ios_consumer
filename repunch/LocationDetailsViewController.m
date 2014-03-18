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
		self.daysLabel.text = nil;
		self.hoursLabel.text = nil;
		return;
	}
	else if([storeLocation.hours lastObject][@"day"] == 0) {
		self.daysLabel.text = @"Open 24/7";
		self.hoursLabel.text = nil;
		return;
	}
	
	NSArray *days = [NSArray arrayWithObjects: @"Sunday", @"Monday", @"Tuesday",
										@"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
	NSMutableAttributedString *dayString = [[NSMutableAttributedString alloc] init];
	NSMutableAttributedString *hourString = [[NSMutableAttributedString alloc] init];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
	NSInteger weekday = [components weekday];
	
	for(NSInteger day = 1; day <= 7; day++)
	{
		NSInteger dayStringBeginIndex = dayString.length;
		NSInteger hourStringBeginIndex = hourString.length;
		
		BOOL found = NO;
		for(id entry in storeLocation.hours)
		{
			if([entry[@"day"] intValue] == day) {
				
				if(!found) {
					[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:days[day - 1]]];
					[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
				} else {
					[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
				}
				
				NSString *openTime = [NSDate formattedDateFromStoreHours:entry[@"open_time"]];
				NSString *closeTime = [NSDate formattedDateFromStoreHours:entry[@"close_time"]];
				
				[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:openTime]];
				[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:@" - "]];
				[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:closeTime]];
				[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
				
				found = YES;
			}
		}
		
		if(!found) {
			[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:days[day - 1]]];
			[dayString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
			[hourString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Closed\n"]];
		}
		
		if(day == weekday) {
			NSInteger dayStringLength = dayString.length - dayStringBeginIndex;
			NSInteger hourStringLength = hourString.length - hourStringBeginIndex;
			
			[dayString addAttribute:NSForegroundColorAttributeName
							  value:[RepunchUtils repunchOrangeColor]
							  range:NSMakeRange(dayStringBeginIndex, dayStringLength)];
			
			[hourString addAttribute:NSForegroundColorAttributeName
							   value:[RepunchUtils repunchOrangeColor]
							   range:NSMakeRange(hourStringBeginIndex, hourStringLength)];
		}
	}
	
	self.daysLabel.attributedText = dayString;
	self.hoursLabel.attributedText = hourString;
}

- (void)addMapAnnotation
{
	coordinates = CLLocationCoordinate2DMake(storeLocation.coordinates.latitude,
											 storeLocation.coordinates.longitude);
	
	[self.mapView setCenterCoordinate:coordinates
							zoomLevel:15
							 animated:NO];
	
	
    RPAnnotation *pin = [[RPAnnotation alloc] initWithCoordinates:coordinates
														placeName:store.store_name
													  description:storeLocation.street
												  storeLocationId:nil];
	MKAnnotationView *annotationView = [self.mapView viewForAnnotation:pin];
	annotationView.image = [UIImage imageNamed:@"star"];
    
    [self.mapView addAnnotation:pin];
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
	self.expandedMapStatusBar.hidden = NO;
	
	[self.expandedMapDirectionsButton showButton];
}

- (void)shrinkMapView
{
	self.mapViewHeightConstraint.constant = 300.0f;
	[self.navigationController setNavigationBarHidden:NO];
	
	self.tapGestureRecognizer.enabled = YES;
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	
	self.expandedMapExitButton.hidden = YES;
	self.expandedMapStatusBar.hidden = YES;
	
	self.expandedMapDirectionsButton.hidden = YES; //[erhaps move to slide animation for hiding button also
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
    [RepunchUtils callPhoneNumber:storeLocation.phone_number];
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
