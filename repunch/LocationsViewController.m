//
//  StoreDetailViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationDetailsViewController.h"
#import "StoreDetailTableViewCell.h"
#import "RPStoreLocation.h"
#import "RepunchUtils.h"

@interface LocationsViewController()

@end

@implementation LocationsViewController
{
	CLLocationManager *locationManager;
	PFGeoPoint *userLocation;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.navigationItem.title = @"Locations";
		
		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
		[self.tableView setTableFooterView:footer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone; //filter out negligible changes in location (disabled for now)
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if(userLocation == nil || abs(howRecent) > 60) //if result is older than 1 minute
	{
		NSLog(@"latitude %+.6f, longitude %+.6f\n",
			  location.coordinate.latitude, location.coordinate.longitude);
		userLocation = [PFGeoPoint geoPointWithLocation:location];
		
		[self reloadTableView];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
	
	switch([error code])
	{
		case kCLErrorDenied:
		{
			[RepunchUtils showCustomDropdownView:self.view withMessage:@"Location Services disabled"];
			break;
		}
		default:
		{
			[RepunchUtils showCustomDropdownView:self.view withMessage:@"Failed to get location"];
			break;
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.locationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreDetailTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [StoreDetailTableViewCell cell];
		
		UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
		selectedView.backgroundColor = [RepunchUtils repunchOrangeHighlightedColor];
		cell.selectedBackgroundView = selectedView;
		
		cell.locationImage.layer.cornerRadius = 8.0;
		cell.locationImage.layer.masksToBounds = YES;
    }
	
	RPStoreLocation *storeLocation = self.locationsArray[indexPath.row];
    
	cell.locationTitle.text = storeLocation.street;
	cell.locationSubtitle.text = [NSString stringWithFormat:@"%@, %@", storeLocation.city, storeLocation.state];
	//cell.locationHours;
	
	if(userLocation != nil) {
		float distanceToStore = [userLocation distanceInMilesTo:storeLocation.coordinates];
		cell.locationDistance.text = [NSString stringWithFormat:@"%.2f mi", distanceToStore];
		cell.locationDistance.hidden = NO;
	}
	else {
		cell.locationDistance.hidden = YES;
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    LocationDetailsViewController *locationDetailsVC = [[LocationDetailsViewController alloc] init];
    locationDetailsVC.storeLocation = self.locationsArray[indexPath.row];
    [self.navigationController pushViewController:locationDetailsVC animated:YES];
}

- (void)reloadTableView
{
	self.locationsArray = [NSMutableArray arrayWithArray:self.store.store_locations];//[self.store.store_locations mutableCopy];
	[self sortLocationsByDistance];
	[self.tableView reloadData];
}

- (void)sortLocationsByDistance
{
	if(userLocation == nil) {
		return;
	}
	
	[self.locationsArray sortUsingComparator:^NSComparisonResult(RPStoreLocation *location1, RPStoreLocation *location2)
	 {
		 double distance1 = [userLocation distanceInMilesTo:location1.coordinates];
		 double distance2 = [userLocation distanceInMilesTo:location2.coordinates];
		 
		 if(distance1 == distance2) {
			 return NSOrderedSame;
		 }
		 else if(distance1 > distance2) {
			 return NSOrderedDescending;
		 }
		 else {
			 return NSOrderedAscending;
		 }
	 }];
}

@end
