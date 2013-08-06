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
	BOOL searchloaded;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	locationManager = [[CLLocationManager alloc] init];	
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone; //filter out negligible changes in location (disabled for now)
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = [self.sharedData patron];
	self.storeIdArray = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	int tableViewHeight = self.view.frame.size.height - 50; //50 is nav bar height
	self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, tableViewHeight) style:UITableViewStylePlain]; //TODO: shorten tableView so can scroll to last row hidden by tab bar
    [self.searchTableView setDataSource:self];
    [self.searchTableView setDelegate:self];
    [self.view addSubview:self.searchTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[locationManager startUpdatingLocation];
	searchloaded = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending image downloads
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(searchloaded == FALSE)
	{
		searchloaded = TRUE;
		// If it's a relatively recent event, turn off updates to save power
		CLLocation* location = [locations lastObject];
		//NSDate* eventDate = location.timestamp;
		//NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		//if (abs(howRecent) < 15.0) {
			// If the event is recent, do something with it.
			NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
		
			userLocation = [PFGeoPoint geoPointWithLocation:location];
			[self performSearch];
		//}
	}
}

- (void) performSearch
{	
    PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
    [storeQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
	[storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation withinMiles:50];
	[storeQuery setLimit:20];
	//TODO: paginate!!!
	
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
	 {
		 if (!error)
		 {
			 for (PFObject *store in results)
			 {
				 NSString *storeId = [store objectId];
				 [self.sharedData addStore:store];
				 [self.storeIdArray addObject:storeId];
			 }
			 
			 //[self sortStoreObjectIdsByPunches];
			 //[myPlacesTableView setContentSize:CGSizeMake(320, 105*results.count)];
			 [self.searchTableView reloadData];
		 }
		 else
		 {
			 NSLog(@"search view controller serror: %@", error);
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
     
	//[[cell punchesPic] setHidden:TRUE];
	//[[cell numberOfPunches] setHidden:TRUE];
	
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
	PFObject *store = [self.sharedData getStore:storeId];
     
	PFGeoPoint *storeLocation = [store objectForKey:@"coordinates"];
	double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
	cell.distance.text = [NSString stringWithFormat:@"%.2f mi", distanceToStore];
     
	NSString *neighborhood = [store valueForKey:@"neighborhood"];
	NSString *city = [store valueForKey:@"city"];
	NSString *street = [store valueForKey:@"street"];
     
	if (neighborhood.length > 0) {
		street = [street stringByAppendingFormat:@", %@", neighborhood];
	}
	else {
		street = [street stringByAppendingFormat:@", %@", city];
	}
     
	NSArray *categories = [[store mutableSetValueForKey:@"categories"] allObjects];
	NSString *formattedCategories = @"";
	for (int i = 0; i < categories.count; i++)
	{
		formattedCategories = [formattedCategories stringByAppendingString:[categories[i] valueForKey:@"name"]];
		
		if (i!= [categories count]-1) {
			formattedCategories = [formattedCategories stringByAppendingFormat:@", "];
		}
	}
	
	PFObject *patronStore = [self.sharedData getPatronStore:storeId];
	
	if(patronStore == nil)
	{
		[cell.punchIcon setHidden:TRUE];
		[cell.numPunches setHidden:TRUE];
	}
	else
	{
		int punches = [[patronStore objectForKey:@"punch_count"] intValue];
		[cell.punchIcon setHidden:FALSE];
		[cell.numPunches setHidden:FALSE];
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
	if(imageFile != nil)
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
	StoreViewController *placesDetailVC = [[StoreViewController alloc]init];
	[self presentViewController:placesDetailVC animated:YES completion:NULL];
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
				 SearchTableViewCell *cell = [self.searchTableView cellForRowAtIndexPath:indexPath]; //TODO: resolve this warning
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

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
