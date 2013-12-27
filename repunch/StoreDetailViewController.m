//
//  StoreDetailViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "StoreLocationViewController.h"
#import "StoreDetailTableViewCell.h"
#import "RPStoreLocation.h"
#import "RepunchUtils.h"

@interface StoreDetailViewController()

@end

@implementation StoreDetailViewController
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
	
    if(abs(howRecent) > 60) //if result is older than 1 minute
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
	return self.store.store_locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreDetailTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [StoreDetailTableViewCell cell];
    }
	
	RPStoreLocation *storeLocation = self.store.store_locations[indexPath.row];
    
	cell.locationTitle.text = storeLocation.street;
	cell.locationSubtitle.text = storeLocation.city;
	//cell.locationHours;
	
	if(userLocation != nil) {
		double distanceToStore = [userLocation distanceInMilesTo:storeLocation.coordinates];
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
    StoreLocationViewController *storeLocationVC = [[StoreLocationViewController alloc] init];
    
    // Push the view controller.
    [self.navigationController pushViewController:storeLocationVC animated:YES];
}

- (void)reloadTableView
{
	[self.tableView reloadData];
	
	
}

- (void)sortStoreObjectIdsByPunches
{/*
	[self.storeIdArray sortUsingComparator:^NSComparisonResult(NSString *objectId1, NSString *objectId2)
	 {
		 PFObject* patronStore1 = [self.sharedData getPatronStore:objectId1];
		 PFObject* patronStore2 = [self.sharedData getPatronStore:objectId2];
		 
		 NSNumber* punchCount1 = [patronStore1 objectForKey:@"punch_count"];
		 NSNumber* punchCount2 = [patronStore2 objectForKey:@"punch_count"];
		 
		 if( [punchCount2 compare:punchCount1] == NSOrderedSame ) {
			 NSNumber* allTimePunchCount1 = [patronStore1 objectForKey:@"all_time_punches"];
			 NSNumber* allTimePunchCount2 = [patronStore2 objectForKey:@"all_time_punches"];
			 return [allTimePunchCount2 compare:allTimePunchCount1];
		 }
		 else {
			 return [punchCount2 compare:punchCount1];
		 }
	 }];*/
}

@end
