//
//  SearchViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchViewController.h"
#import "RPButton.h"
#import "LocationManager.h"
#import "RPActivityIndicatorView.h"

#define PAGINATE_COUNT 15

@implementation SearchViewController
{
	PFObject* patron;
	NSMutableArray *storeLocationIdArray;
	NSMutableDictionary *imageDownloadsInProgress;
	
	PFGeoPoint *userLocation;
	BOOL searchResultsLoaded;
	int paginateCount;
	BOOL paginateReachEnd;
	BOOL loadInProgress;
	UIActivityIndicatorView *spinner;
	RPButton *paginateButton;
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

	patron = [[DataManager getSharedInstance] patron];
	storeLocationIdArray = [NSMutableArray array];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	spinner.hidesWhenStopped = YES;
	paginateCount = 0;
	paginateReachEnd = NO;
	loadInProgress = NO;
	searchResultsLoaded = NO;
	
	__weak typeof(self) weakSelf = self;
	[self.tableView addPullToRefreshActionHandler:^{
		[weakSelf performSearch:NO];
	}];
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
	
	// terminate all pending image downloads
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [imageDownloadsInProgress removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
	self.navigationItem.title = @"Nearby Stores";
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				target:self
																				action:@selector(closeView)];
	self.navigationItem.leftBarButtonItem = exitButton;
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
	
	reach.reachableBlock = ^(Reachability *reach) {
		if(storeLocationIdArray.count == 0) {
			//[weakSelf startUpdatingLocationForSearch];
		}
		else {
			[weakSelf refreshTableView];
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
			 
			 self.locationServicesLabel.hidden = YES;
			 userLocation = [PFGeoPoint geoPointWithLocation:location];
			 [self performSearch:NO];
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
						 self.locationServicesLabel.hidden = NO;
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
		[self.tableView stopRefreshAnimation];
		return;
	}
	
	if(userLocation == nil) {
		return;
	}
	
	loadInProgress = YES;
	
    PFQuery *storeQuery = [RPStoreLocation query];
	[storeQuery includeKey:@"Store.store_locations"];
    //[storeQuery includeKey:@"Store.active" equalTo:[NSNumber numberWithBool:YES]];
	//[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation withinMiles:30];
	[storeQuery setLimit:PAGINATE_COUNT];
	
	if(paginate == YES) {
		++paginateCount;
		[storeQuery setSkip:paginateCount*PAGINATE_COUNT];
		
		[self.tableView setPaginationFooter];
	}
	else if(storeLocationIdArray.count == 0) {
		[self.activityIndicatorView setHidden:NO];
		[self.activityIndicator startAnimating];
	}
	
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		
		if(paginate == NO) {
			[self.tableView stopRefreshAnimation];
			[self.activityIndicatorView setHidden:YES];
			[self.activityIndicator stopAnimating];
			[storeLocationIdArray removeAllObjects];
		}
		else {
			[self.tableView setDefaultFooter];
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
			 
			 //if(paginate != NO && results.count == 0) {
			 if(paginateCount >= 1) {
				paginateReachEnd = YES;
			 }
			 
			 [self refreshTableView];
		 }
		 else {
			 NSLog(@"search view controller serror: %@", error);
			 [RepunchUtils showConnectionErrorDialog];
		 }
		
		loadInProgress = NO;
	}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return storeLocationIdArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [SearchTableViewCell cell];
    }
	
	NSString *storeLocationId = storeLocationIdArray[indexPath.row];
	RPStoreLocation *storeLocation = [[DataManager getSharedInstance] getStoreLocation:storeLocationId];
	RPStore *store = [[DataManager getSharedInstance] getStore:storeLocation.Store.objectId];

	// Set distance to store
	double distanceToStore = [userLocation distanceInMilesTo:storeLocation.coordinates];
	cell.distance.text = [RepunchUtils formattedDistance:distanceToStore];
	
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
	
	for (int i = 0; i < store.categories.count; i++)
	{
		formattedCategories = [formattedCategories stringByAppendingString:store.categories[i][@"name"]];
		
		if (i != [store.categories count] - 1) {
			formattedCategories = [formattedCategories stringByAppendingFormat:@", "];
		}
	}
	
	// Set punches and reward info
	RPPatronStore *patronStore = [[DataManager getSharedInstance] getPatronStore:store.objectId];
	
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
	cell.storeName.text = store.store_name;
	
	// Only load cached images; defer new downloads until scrolling ends
    //if (cell.storeImage == nil)
    //{
	//if (self.myPlacesTableView.dragging == NO && self.myPlacesTableView.decelerating == NO)
	//{
	if( !IS_NIL(store.thumbnail_image) )
	{
		cell.storeImage.image = [UIImage imageNamed:@"placeholder_thumbnail_image"];
		UIImage *storeImage = [[DataManager getSharedInstance] getThumbnailImage:store.objectId];
		if(storeImage == nil)
		{
			cell.storeImage.image = [UIImage imageNamed:@"placeholder_thumbnail_image"];
			[self downloadImage:store.thumbnail_image forIndexPath:indexPath withStoreId:store.objectId];
		} else {
			cell.storeImage.image = storeImage;
		}
	} else {
		// if a download is deferred or in progress, return a placeholder image
		cell.storeImage.image = [UIImage imageNamed:@"placeholder_thumbnail_image"];
	}
	//}
    //}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *storeLocationId = storeLocationIdArray[indexPath.row];
	RPStoreLocation *storeLocation = [[DataManager getSharedInstance] getStoreLocation:storeLocationId];
	
	StoreViewController *storeVC = [[StoreViewController alloc] init];
	storeVC.storeId = storeLocation.Store.objectId;
	storeVC.storeLocationId = storeLocationId;
	[self.navigationController pushViewController:storeVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollLocation = MIN(scrollView.contentSize.height, scrollView.bounds.size.height) + scrollView.contentOffset.y - scrollView.contentInset.bottom;
    float scrollHeight = MAX(scrollView.contentSize.height, scrollView.bounds.size.height);
	
    if(scrollLocation >= scrollHeight + 5 && !loadInProgress && !paginateReachEnd)
	{
		[self performSearch:YES];
    }
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		return;
	}
	
    PFFile *existingImageFile = imageDownloadsInProgress[indexPath];
    if (existingImageFile == nil)
    {
        [imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			 
			if (!error) {
				 SearchTableViewCell *cell = (SearchTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
				 UIImage *storeImage = [UIImage imageWithData:data];
				 //cell.storeImage.image = storeImage;
				 [cell.storeImage setImageWithAnimation:storeImage];
				 [imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				 [[DataManager getSharedInstance] addThumbnailImage:storeImage forKey:storeId];
			}
			else {
				NSLog(@"image download failed");
			}
		}];
    }
}

- (void)cancelImageDownload
{
    for(PFFile *imageFile in imageDownloadsInProgress)
    {
        [imageFile cancel];
    }
}

- (void)refreshTableView
{
	if(storeLocationIdArray.count > 0) {
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
