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
#import "LocationManager.h"

@implementation LocationsViewController
{
	RPStore *store;
	PFGeoPoint *userLocation;
	NSMutableArray *locationsArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	store = [[DataManager getSharedInstance] getStore:self.storeId];
	
	self.navigationItem.title = @"Locations";
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[LocationManager getSharedInstance] startUpdatingLocationWithBlock:
	 ^(CLLocationManager *manager, CLLocation *location, NSError *error) {
		 
		 userLocation = [PFGeoPoint geoPointWithLocation:location];
		 [self reloadTableView];
	 }];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[LocationManager getSharedInstance] stopUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return locationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[LocationsTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [LocationsTableViewCell cell];
    }
	
	RPStoreLocation *storeLocation = locationsArray[indexPath.row];
    
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
    locationDetailsVC.storeLocationId = [locationsArray[indexPath.row] objectId];
    [self.navigationController pushViewController:locationDetailsVC animated:YES];
}

- (void)reloadTableView
{
	locationsArray = [store.store_locations mutableCopy];
	[self sortLocationsByDistance];
	[self.tableView reloadData];
}

- (void)sortLocationsByDistance
{
	if(userLocation == nil) {
		return;
	}
	
	[locationsArray sortUsingComparator:^NSComparisonResult(RPStoreLocation *location1, RPStoreLocation *location2) {
		
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
