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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadTableView)
												 name:@"Punch"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadTableView)
												 name:@"Redeem"
											   object:nil];
	
	self.navigationItem.title = @"Search";
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"nav_exit.png"]
								   style:UIBarButtonItemStylePlain
								   target:self
								   action:@selector(closeView:)];
	
	self.navigationItem.leftBarButtonItem = exitButton;
	
	locationManager = [[CLLocationManager alloc] init];
	
	//[self checkLocationManagerPermissions];
	
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone; //filter out negligible changes in location (disabled for now)
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = [self.sharedData patron];
	self.storeIdArray = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
	self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - navBarHeight)
														style:UITableViewStylePlain];
    [self.searchTableView setDataSource:self];
    [self.searchTableView setDelegate:self];
    [self.view addSubview:self.searchTableView];
	self.searchTableView.layer.zPosition = -1.0;
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	paginateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
	paginateButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:17];
	paginateButton.adjustsImageWhenDisabled = NO;
	[paginateButton.layer setCornerRadius:10];
	[paginateButton setClipsToBounds:YES];
	[paginateButton addTarget:self action:@selector(performSearch:) forControlEvents:UIControlEventTouchUpInside];
	
	[paginateButton setBackgroundImage:[GradientBackground orangeButtonNormal:paginateButton]
									forState:UIControlStateNormal];
	[paginateButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:paginateButton]
									forState:UIControlStateHighlighted];
	
	[paginateButton setTitle:@"More Results" forState:UIControlStateNormal];
	
	spinner.hidesWhenStopped = YES;
	paginateCount = 0;
	paginateReachEnd = NO;
	searchResultsLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation* location = [locations lastObject];
	NSDate* eventDate = location.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if(abs(howRecent) > 120 || !searchResultsLoaded) //if result is older than 2 minutes
	{
		NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
		userLocation = [PFGeoPoint geoPointWithLocation:location];
		
		searchResultsLoaded = YES;
		paginateCount = 0;
		paginateReachEnd = NO;
		
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
			SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Location Services disabled"
														 andMessage:@"Location Services for Repunch can be enabled in Settings -> Privacy -> Location"];
			[alert addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
								  [alert dismissAnimated:YES];
								  [self dismissViewControllerAnimated:YES completion:nil];
							  }];
			[alert show];
			break;
		}
		default:
		{
			SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Failed to get location"
														 andMessage:nil];
			[alert addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
								  [alert dismissAnimated:YES];
								  [self dismissViewControllerAnimated:YES completion:nil];
							  }];
			[alert show];
			break;
		}
	}
}

- (void)performSearch:(BOOL)paginate
{
    PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
    [storeQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation withinMiles:50];
	[storeQuery setLimit:20];
	
	if(paginate == NO)
	{
		[self.activityIndicatorView setHidden:NO];
		[self.activityIndicator startAnimating];
	}
	else
	{
		++paginateCount;
		[storeQuery setSkip:paginateCount*20];
	}
	[self setFooter:YES];
	
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
	{
		 if(paginate == NO)
		 {
			 [self.activityIndicatorView setHidden:YES];
			 [self.activityIndicator stopAnimating];
			 [self.storeIdArray removeAllObjects];
		 }
		 
		 if (!error)
		 {
				for (PFObject *store in results)
				{
					NSString *storeId = [store objectId];
					[self.sharedData addStore:store];
					[self.storeIdArray addObject:storeId];
				}
				 
				if(paginate != NO && results.count == 0) {
					paginateReachEnd = YES;
				}
			 
				[self refreshTableView];
				[self setFooter:NO];
		 }
		 else
		 {
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
	return [self.storeIdArray count];
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [SearchTableViewCell cell];
    }
	
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
	PFObject *store = [self.sharedData getStore:storeId];
     
	PFGeoPoint *storeLocation = [store objectForKey:@"coordinates"];
	double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
	cell.distance.text = [NSString stringWithFormat:@"%.2f mi", distanceToStore];
     
	NSString *neighborhood = [store objectForKey:@"neighborhood"];
	NSString *city = [store objectForKey:@"city"];
	NSString *street = [store objectForKey:@"street"];
     
	if ( !IS_NIL(neighborhood) ) {
		street = [street stringByAppendingFormat:@", %@", neighborhood];
	}
	else {
		street = [street stringByAppendingFormat:@", %@", city];
	}
     
	NSArray *categories = [[store mutableSetValueForKey:@"categories"] allObjects];
	NSString *formattedCategories = @"";
	for (int i = 0; i < categories.count; i++)
	{
		formattedCategories = [formattedCategories stringByAppendingString:[categories[i] objectForKey:@"name"]];
		
		if (i!= [categories count]-1) {
			formattedCategories = [formattedCategories stringByAppendingFormat:@", "];
		}
	}
	
	PFObject *patronStore = [self.sharedData getPatronStore:storeId];
	
	if(patronStore == nil)
	{
		[cell.punchIcon setHidden:YES];
		[cell.numPunches setHidden:YES];
	}
	else
	{
		int punches = [[patronStore objectForKey:@"punch_count"] intValue];
		[cell.punchIcon setHidden:NO];
		[cell.numPunches setHidden:NO];
		[cell.numPunches setText:[NSString stringWithFormat:@"%d %@", punches, (punches==1) ? @"punch" : @"punches"]];
	}
	
	cell.storeAddress.text = street;
	cell.storeCategories.text = formattedCategories;
	cell.storeName.text = [store objectForKey:@"store_name"];
	cell.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
	
	// Only load cached images; defer new downloads until scrolling ends
    //if (cell.storeImage == nil)
    //{
	//if (self.myPlacesTableView.dragging == NO && self.myPlacesTableView.decelerating == NO)
	//{
	PFFile *imageFile = [store objectForKey:@"store_avatar"];
	if( !IS_NIL(imageFile) )
	{
		UIImage *storeImage = [self.sharedData getStoreImage:storeId];
		if(storeImage == nil)
		{
			cell.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
			[self downloadImage:imageFile forIndexPath:indexPath withStoreId:storeId];
		} else {
			cell.storeImage.image = storeImage;
		}
	} else {
		// if a download is deferred or in progress, return a placeholder image
		cell.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
	}
	//}
    //}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
	StoreViewController *storeVC = [[StoreViewController alloc]init];
	storeVC.storeId = storeId;
	storeVC.delegate = self;
	[self.navigationController pushViewController:storeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
    PFFile *existingImageFile = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (existingImageFile == nil)
    {
        [self.imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
		 {
			 if (!error)
			 {
				 SearchTableViewCell *cell = (id)[self.searchTableView cellForRowAtIndexPath:indexPath];
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

- (void)updateTableViewFromStore:(StoreViewController *)controller forStoreId:(NSString *)storeId andAddRemove:(BOOL)isAddRemove
{
	NSLog(@"storeVC->searchVC delegate:update TableView");
    [self.searchTableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(updateTableViewFromSearch:forStoreId:andAddRemove:)]) {
        [self.delegate updateTableViewFromSearch:self forStoreId:storeId andAddRemove:isAddRemove];
    }
}

- (void)reloadTableView
{
	[self.searchTableView reloadData];
}

- (void)setFooter:(BOOL)loadInProgress
{	
	if(self.storeIdArray.count >= 20 && !paginateReachEnd)
	{
		UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
		footer.backgroundColor = [UIColor clearColor];
		self.searchTableView.tableFooterView = footer;
		
		CGRect paginateButtonFrame = CGRectMake(footer.frame.size.width/2 - paginateButton.frame.size.width/2,
												footer.frame.size.height/2 - paginateButton.frame.size.height/2,
												paginateButton.frame.size.width,
												paginateButton.frame.size.height);
		paginateButton.enabled = !loadInProgress;
		paginateButton.frame = paginateButtonFrame;
		[self.searchTableView.tableFooterView addSubview:paginateButton];
	
		if(loadInProgress)
		{
			[paginateButton setHidden:YES];
			spinner.frame = self.searchTableView.tableFooterView.bounds;
			[self.searchTableView.tableFooterView addSubview:spinner];
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
		[self.searchTableView setTableFooterView:footer];
	}
}

- (void)refreshTableView
{
	if(self.storeIdArray.count > 0) {
		[self.emptyResultsLabel setHidden:YES];
	}
	else {
		[self.emptyResultsLabel setHidden:NO];
	}
	[self.searchTableView reloadData];
}

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
