//
//  SearchViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 3/14/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "SearchViewController.h"
#import "LocationManager.h"
#import "Reachability.h"

#define PAGINATE_INCREMENT 15
#define NEARBY_RADIUS 30

@interface SearchViewController ()

@end

@implementation SearchViewController
{
	PFObject* patron;
	NSMutableArray *storeLocationIdArray;
	PFGeoPoint *userLocation;
	BOOL searchResultsLoaded;
	int paginateCount;
	BOOL paginateReachEnd;
	BOOL loadInProgress;
	BOOL mapViewMode;
	UIBarButtonItem *toggleButton;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableViewController = [[SearchTableViewController alloc] init];
	self.tableViewController.delegate = self;
	self.mapViewController = [[SearchMapViewController alloc] init];
	[self addChildViewController:self.tableViewController];
	[self addChildViewController:self.mapViewController];
	[self.view addSubview:self.tableViewController.view];
	[self.mapViewController view];
	
	[self registerForNotifications];
	[self setupNavigationBar];
	
	patron = [[DataManager getSharedInstance] patron];
	storeLocationIdArray = [NSMutableArray array];
	
	paginateCount = 0;
	paginateReachEnd = NO;
	loadInProgress = NO;
	searchResultsLoaded = NO;
	mapViewMode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[RepunchUtils setupNavigationController:self.navigationController];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	[self startUpdatingLocationForSearch];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	[[LocationManager getSharedInstance] stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
	self.navigationItem.title = @"Nearby Stores";
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				target:self
																				action:@selector(closeView)];
	self.navigationItem.leftBarButtonItem = exitButton;
	
	toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Map"
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(toggleBetweenListAndMap)];
	self.navigationItem.rightBarButtonItem = toggleButton;
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateChildViewControllers)
												 name:@"AddOrRemoveStore"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateChildViewControllers)
												 name:@"Punch"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateChildViewControllers)
												 name:@"Redeem"
											   object:nil];
	
	__weak typeof(self) weakSelf = self;
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	reach.reachableBlock = ^(Reachability *reach) {
		if(storeLocationIdArray.count == 0) {
			[weakSelf performSearch:NO];
		}
		else {
			[weakSelf.tableViewController refreshTableView];
		}
	};
	[reach startNotifier];
}

- (void)startUpdatingLocationForSearch
{
	[[LocationManager getSharedInstance] startUpdatingLocationWithBlock:
	 ^(CLLocationManager *manager, CLLocation *location, NSError *error) {
		 
		 if(!error) {
			 [[LocationManager getSharedInstance] stopUpdatingLocation];
			 
			 self.tableViewController.locationServicesLabel.hidden = YES;
			 PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLocation:location];
			 
			 // ignore location changes smaller than 50 meters
			 if(userLocation == nil || [userLocation distanceInKilometersTo:newLocation] >= 0.05) {
				 userLocation = newLocation;
				 [self.tableViewController showRefreshViews:NO];
				 [self performSearch:NO];
			 }
		 }
		 else {
			 switch([error code])
			 {
				 case kCLErrorDenied:
				 {
					 [RepunchUtils showDialogWithTitle:@"Location Services disabled"
										   withMessage:
					  @"Location Services for Repunch can be enabled in\nSettings -> Privacy -> Location"];
					 
					 if(storeLocationIdArray.count == 0) {
						 self.tableViewController.locationServicesLabel.hidden = NO;
					 }
					 break;
				 }
				 default:
				 {
					 [RepunchUtils showCustomDropdownView:self.view withMessage:@"Failed to get location"];
					 break;
				 }
			 }
		 }
	 }];
}

- (void)performSearch:(BOOL)paginate
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		[self.tableViewController hideRefreshViews:paginate];
		return;
	}
	
	if( userLocation == nil || loadInProgress || (paginate && paginateReachEnd) ) {
		[self.tableViewController hideRefreshViews:paginate];
		return;
	}
	
	loadInProgress = YES;
	
    PFQuery *storeQuery = [RPStoreLocation query];
	[storeQuery includeKey:@"Store.store_locations"];
    //[storeQuery whereKey:@"Store.active" equalTo:[NSNumber numberWithBool:YES]];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation withinMiles:NEARBY_RADIUS];
	[storeQuery setLimit:PAGINATE_INCREMENT];
	
	if(paginate == YES) {
		++paginateCount;
		[storeQuery setSkip:paginateCount*PAGINATE_INCREMENT];
	}
	
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		
		[self.tableViewController hideRefreshViews:paginate];
		
		if(paginate == NO) {
			[storeLocationIdArray removeAllObjects];
		}
		
		if (!error) {
			if(paginate == NO) {
				searchResultsLoaded = YES;
				paginateCount = 0;
				paginateReachEnd = NO;
			}
			
			for (RPStoreLocation *storeLocation in results) {
				if(storeLocation.Store.active) {
					[[DataManager getSharedInstance] addStore:storeLocation.Store];
					[storeLocationIdArray addObject:storeLocation.objectId];
				}
			}
			
			if(paginateCount >= 1) { //shortcut for limiting to 30 results
				paginateReachEnd = YES;
			}
			
			[self updateChildViewControllers];
		}
		else {
			NSLog(@"search view controller error: %@", error);
			[RepunchUtils showConnectionErrorDialog];
		}
		
		loadInProgress = NO;
	}];
}

- (void)refreshData:(SearchTableViewController *)controller forPaginate:(BOOL)paginate
{
	[self performSearch:paginate];
}

- (void)toggleBetweenListAndMap
{
	id oldVC = mapViewMode ? self.mapViewController : self.tableViewController;
	id newVC = mapViewMode ? self.tableViewController : self.mapViewController;
	
	[oldVC willMoveToParentViewController:self];
    [self addChildViewController:newVC];
	
	mapViewMode = !mapViewMode;
	toggleButton.title = mapViewMode ? @"List" : @"Map";
	toggleButton.enabled = NO;
	UIViewAnimationOptions animationOption = mapViewMode ?
		UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft;
	
    [self transitionFromViewController:oldVC
					  toViewController:newVC
							  duration: 0.5
							   options:animationOption
							animations:nil
							completion:^(BOOL finished) {
								[oldVC removeFromParentViewController];
								[newVC didMoveToParentViewController:self];
								toggleButton.enabled = YES;
							}];
}

- (void)updateChildViewControllers
{
	self.tableViewController.storeLocationIdArray = storeLocationIdArray;
	self.tableViewController.userLocation = userLocation;
	[self.tableViewController refreshTableView];
	
	self.mapViewController.storeLocationIdArray = storeLocationIdArray;
	self.mapViewController.userLocation = userLocation;
	[self.mapViewController refreshMapView];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
