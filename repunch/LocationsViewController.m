//
//  StoreDetailViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationDetailsViewController.h"
#import "LocationsTableViewCell.h"
#import "RPStoreLocation.h"
#import "RepunchUtils.h"
#import "DataManager.h"

@implementation LocationsViewController
{
	RPStore *store;
	CLLocationManager *locationManager;
	PFGeoPoint *userLocation;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.navigationItem.title = @"Locations";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	store = [[DataManager getSharedInstance] getStore:self.storeId];
	
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
	
	[self reloadTableView];
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
    LocationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[LocationsTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [LocationsTableViewCell cell];
    }
	
	RPStoreLocation *storeLocation = self.locationsArray[indexPath.row];
    
	cell.locationTitle.text = storeLocation.street;
	cell.locationSubtitle.text = [NSString stringWithFormat:@"%@, %@", storeLocation.city, storeLocation.state];
	
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
    locationDetailsVC.storeLocationId = [self.locationsArray[indexPath.row] objectId];
    [self.navigationController pushViewController:locationDetailsVC animated:YES];
}

- (void)reloadTableView
{
	self.locationsArray = [NSMutableArray arrayWithArray:store.store_locations];//[self.store.store_locations mutableCopy];
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
