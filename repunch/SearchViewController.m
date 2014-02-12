//
//  PlacesSearchViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController
{
	CLLocationManager *locationManager;
	PFGeoPoint *userLocation;
	BOOL searchResultsLoaded;
	int paginateCount;
	BOOL paginateReachEnd;
	UIActivityIndicatorView *spinner;
	UIButton *paginateButton;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self registerForNotifications];
	[self setupNavigationBar];
	[self setupTableView];

	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone; //filter out negligible changes in location (disabled for now)
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = [self.sharedData patron];
	self.storeLocationIdArray = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	spinner.hidesWhenStopped = YES;
	paginateCount = 0;
	paginateReachEnd = NO;
	searchResultsLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[RepunchUtils setupNavigationController:self.navigationController];
    [super viewWillAppear:animated];
	[locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	NSLog(@"Search didReceiveMemoryWarning");
    
    // terminate all pending image downloads
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
	self.navigationItem.title = @"Nearby Stores";
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				target:self
																				action:@selector(closeView)];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				   target:self
																				   action:@selector(refreshSearch)];
	self.navigationItem.leftBarButtonItem = exitButton;
	self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:@"AddOrRemoveStore"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:@"Punch"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:@"Redeem"
											   object:nil];
	
	__weak typeof(self) weakSelf = self;
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	reach.reachableBlock = ^(Reachability*reach) {
		if(weakSelf.storeLocationIdArray.count == 0) {
			[weakSelf refreshSearch];
		}
		else {
			[weakSelf refreshTableView];
		}
	};
	
	[reach startNotifier];
}

- (void)setupTableView
{
	/*
	self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	//self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
	//[self.tableViewController.refreshControl addTarget:self
	//											action:@selector(loadMyPlaces)
	//								  forControlEvents:UIControlEventValueChanged];
	
    self.tableViewController.view.frame = self.view.bounds;
	self.tableViewController.view.layer.zPosition = -1;
	
    [self.tableViewController.tableView setDataSource:self];
    [self.tableViewController.tableView setDelegate:self];
	*/
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.tableView setTableFooterView:footer];
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	paginateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
	[RepunchUtils setDefaultButtonStyle:paginateButton];
	paginateButton.titleLabel.font = [RepunchUtils repunchFontWithSize:17 isBold:YES];
	paginateButton.adjustsImageWhenDisabled = NO;
	[paginateButton addTarget:self action:@selector(paginate) forControlEvents:UIControlEventTouchUpInside];
	[paginateButton.layer setCornerRadius:10];
	[paginateButton setClipsToBounds:YES];
	
	[paginateButton setTitle:@"More Results" forState:UIControlStateNormal];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	self.locationServicesLabel.hidden = YES;
	
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if(abs(howRecent) > 120 || !searchResultsLoaded) //if result is older than 2 minutes
	{
		NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
		userLocation = [PFGeoPoint geoPointWithLocation:location];
		
		[self performSearch:NO];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[manager stopUpdatingLocation];
	NSLog(@"location manager failed with error%@", error);
	
	switch([error code])
	{
		case kCLErrorDenied:
		{
			[RepunchUtils showDialogWithTitle:@"Location Services disabled"
								  withMessage:
			 @"Location Services for Repunch can be enabled in\nSettings -> Privacy -> Location"];
			
			if(self.storeLocationIdArray.count == 0) {
				self.locationServicesLabel.hidden = NO;
			}
			break;
		}
		default:
		{
			//[RepunchUtils showDialogWithTitle:@"Failed to get location" withMessage:nil];
			[RepunchUtils showCustomDropdownView:self.view withMessage:@"Failed to get location"];
			break;
		}
	}
}

- (void)refreshSearch
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	[locationManager startUpdatingLocation];
}

- (void)performSearch:(BOOL)paginate
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
    PFQuery *storeQuery = [RPStoreLocation query];
	[storeQuery includeKey:@"Store"];
    //[storeQuery whereKey:@"Store.active" equalTo:[NSNumber numberWithBool:YES]];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation withinMiles:50];
	[storeQuery setLimit:20];
	
	if(paginate == YES) {
		++paginateCount;
		[storeQuery setSkip:paginateCount*20];
	}
	else if(self.storeLocationIdArray.count == 0) {
		[self.activityIndicatorView setHidden:NO];
		[self.activityIndicator startAnimating];
	}
	[self setFooter:YES];
	
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		
		 if(paginate == NO) {
			 [self.activityIndicatorView setHidden:YES];
			 [self.activityIndicator stopAnimating];
			 [self.storeLocationIdArray removeAllObjects];
		 }
		 
		 if (!error) {
			 if(paginate == NO) {
				 searchResultsLoaded = YES;
				 paginateCount = 0;
				 paginateReachEnd = NO;
			 }
			
			 for (RPStoreLocation *storeLocation in results) {
				 [self.sharedData addStoreLocation:storeLocation];
				 [self.sharedData addStore:storeLocation.Store];
				 [self.storeLocationIdArray addObject:storeLocation.objectId];
			 }
			 
			 if(paginate != NO && results.count == 0) {
				paginateReachEnd = YES;
			 }
			 
			 [self refreshTableView];
			 [self setFooter:NO];
		 }
		 else {
			 NSLog(@"search view controller serror: %@", error);
			 [RepunchUtils showConnectionErrorDialog];
		 }
	 }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.storeLocationIdArray count];
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [SearchTableViewCell cell];
    }
	
	NSString *storeLocationId = self.storeLocationIdArray[indexPath.row];
	RPStoreLocation *storeLocation = [self.sharedData getStoreLocation:storeLocationId];

	// Set distance to store
	double distanceToStore = [userLocation distanceInMilesTo:storeLocation.coordinates];
	if(distanceToStore < 0.1) {
		cell.distance.text = [NSString stringWithFormat:@"%.0f ft", distanceToStore*5280];
	}
	else {
		cell.distance.text = [NSString stringWithFormat:@"%.1f mi", distanceToStore];
	}
	
	// Set address
	NSString *street = storeLocation.street;
	
	if ( !IS_NIL(storeLocation.neighborhood) ) {
		street = [street stringByAppendingFormat:@", %@", storeLocation.neighborhood];
	}
	else {
		street = [street stringByAppendingFormat:@", %@", storeLocation.city];
	}
	
	// Set Categories
	NSString *formattedCategories = @"";
	
	for (int i = 0; i < storeLocation.Store.categories.count; i++)
	{
		formattedCategories = [formattedCategories stringByAppendingString:storeLocation.Store.categories[i][@"name"]];
		
		if (i != [storeLocation.Store.categories count] - 1) {
			formattedCategories = [formattedCategories stringByAppendingFormat:@", "];
		}
	}
	
	// Set punches and reward info
	RPPatronStore *patronStore = [self.sharedData getPatronStore:storeLocation.Store.objectId];
	
	if(patronStore == nil) {
		[cell.punchIcon setHidden:YES];
		[cell.numPunches setHidden:YES];
	}
	else {
		NSInteger punchCount = patronStore.punch_count;
		[cell.punchIcon setHidden:NO];
		[cell.numPunches setHidden:NO];
		[cell.numPunches setText:[NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch" : @"Punches"]];
	}
	
	cell.storeAddress.text = street;
	cell.storeCategories.text = formattedCategories;
	cell.storeName.text = storeLocation.Store.store_name;
	cell.storeImage.image = [UIImage imageNamed:@"store_placeholder.png"];
	
	// Only load cached images; defer new downloads until scrolling ends
    //if (cell.storeImage == nil)
    //{
	//if (self.myPlacesTableView.dragging == NO && self.myPlacesTableView.decelerating == NO)
	//{
	if( !IS_NIL(storeLocation.cover_image) )
	{
		UIImage *storeImage = [self.sharedData getStoreImage:storeLocationId];
		if(storeImage == nil)
		{
			cell.storeImage.image = [UIImage imageNamed:@"store_placeholder.png"];
			[self downloadImage:storeLocation.cover_image forIndexPath:indexPath withStoreId:storeLocationId];
		} else {
			cell.storeImage.image = storeImage;
		}
	} else {
		// if a download is deferred or in progress, return a placeholder image
		cell.storeImage.image = [UIImage imageNamed:@"store_placeholder.png"];
	}
	//}
    //}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *storeLocationId = self.storeLocationIdArray[indexPath.row];
	NSString *storeId = [self.sharedData getStoreLocation:storeLocationId].Store.objectId;
	
	StoreViewController *storeVC = [[StoreViewController alloc] init];
	storeVC.storeId = storeId;
	storeVC.storeLocationId = storeLocationId;
	[self.navigationController pushViewController:storeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		return;
	}
	
    PFFile *existingImageFile = self.imageDownloadsInProgress[indexPath];
    if (existingImageFile == nil)
    {
        [self.imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
		 {
			 if (!error)
			 {
				 SearchTableViewCell *cell = (SearchTableViewCell *)
												[self.tableView cellForRowAtIndexPath:indexPath];
				 UIImage *storeImage = [UIImage imageWithData:data];
				 cell.storeImage.image = storeImage;
				 [self.imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				 [self.sharedData addStoreImage:storeImage forKey:storeId];
			 }
			 else
			 {
				 NSLog(@"image download failed");
			 }
		 }];
    }
}

- (void)cancelImageDownload
{
    for(PFFile *imageFile in self.imageDownloadsInProgress)
    {
        [imageFile cancel];
    }
}

- (void)paginate
{
	[self performSearch:YES];
}

- (void)setFooter:(BOOL)loadInProgress
{	
	if(self.storeLocationIdArray.count >= 20 && !paginateReachEnd)
	{
		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
		footer.backgroundColor = [UIColor clearColor];
		self.tableView.tableFooterView = footer;
		
		CGRect paginateButtonFrame = CGRectMake(footer.frame.size.width/2 - paginateButton.frame.size.width/2,
												footer.frame.size.height/2 - paginateButton.frame.size.height/2,
												paginateButton.frame.size.width,
												paginateButton.frame.size.height);
		paginateButton.enabled = !loadInProgress;
		paginateButton.frame = paginateButtonFrame;
		[self.tableView.tableFooterView addSubview:paginateButton];
	
		if(loadInProgress)
		{
			[paginateButton setHidden:YES];
			spinner.frame = self.tableView.tableFooterView.bounds;
			[self.tableView.tableFooterView addSubview:spinner];
			[spinner startAnimating];
		}
		else
		{
			[paginateButton setHidden:NO];
			[spinner removeFromSuperview];
			[spinner stopAnimating];
		}
	}
	else
	{
		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
		footer.backgroundColor = [UIColor clearColor];
		self.tableView.tableFooterView = footer;
	}
}

- (void)refreshTableView
{
	if(self.storeLocationIdArray.count > 0) {
		[self.emptyResultsLabel setHidden:YES];
	}
	else {
		[self.emptyResultsLabel setHidden:NO];
	}
	[self.tableView reloadData];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
