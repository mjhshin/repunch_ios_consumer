//
//  MyPlacesViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"

@interface MyPlacesViewController ()
@property (nonatomic, strong) UITableViewController *tableViewController;

@end

@implementation MyPlacesViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = [self.sharedData patron];
	self.storeIdArray = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	[self registerForNotifications];
	[self setupNavigationBar];
	[self setupTableView];
	[self loadMyPlaces];
	[self showHelpViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	NSLog(@"My Places didReceiveMemoryWarning");
    
    // terminate all pending image downloads
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showHelpViews
{
	if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"kRPShowInstructions"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowInstructions"];
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowPunchCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		NSString *punchCode = [self.patron objectForKey:@"punch_code"];
		NSString *message = [NSString stringWithFormat:@"Your Punch Code is %@\n\nYou can always click on the Repunch logo if you forget.", punchCode];
		
		[RepunchUtils showDialogWithTitle:@"Welcome!"
							  withMessage:message];
		
		
    }
	else if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"kRPShowPunchCode"]]) {
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowPunchCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		[self showPunchCode];
    }
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receiveRefreshNotification:)
												 name:@"AddOrRemoveStore"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receiveRefreshNotification:)
												 name:@"Punch"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:@"Redeem"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:@"FacebookPost"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshWhenBackgroundRefreshDisabled)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
	
	__weak typeof(self) weakSelf = self;
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	reach.reachableBlock = ^(Reachability*reach) {
		if(weakSelf.storeIdArray.count == 0) {
			[weakSelf loadMyPlaces];
		}
		else {
			[weakSelf refreshTableView];
		}
	};
	
	[reach startNotifier];
}

- (void)setupNavigationBar
{
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_settings.png"]
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(openSettings)];
	
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_search.png"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(openSearch)];
	
	UIButton *punchCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
	[punchCodeButton setImage:[UIImage imageNamed:@"repunch-logo.png"] forState:UIControlStateNormal];
	[punchCodeButton addTarget:self action:@selector(showPunchCode) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.leftBarButtonItem = settingsButton;
	self.navigationItem.rightBarButtonItem = searchButton;
	self.navigationItem.titleView = punchCodeButton;
}

- (void)setupTableView
{
	self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(loadMyPlaces)
									  forControlEvents:UIControlEventValueChanged];
    

    self.tableViewController.view.frame = self.view.bounds;
	self.tableViewController.view.layer.zPosition = -1;

    [self.tableViewController.tableView setDataSource:self];
    [self.tableViewController.tableView setDelegate:self];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.tableViewController.tableView setTableFooterView:footer];
	
    [self.view addSubview:self.tableViewController.tableView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)loadMyPlaces
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[self.tableViewController.refreshControl endRefreshing];
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(self.storeIdArray.count == 0) {
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
	}
	self.emptyMyPlacesLabel.hidden = YES;
	
    PFRelation *patronStoreRelation = [self.patron relationforKey:@"PatronStores"];
    PFQuery *patronStoreQuery = [patronStoreRelation query];
    [patronStoreQuery includeKey:@"Store"];
	[patronStoreQuery includeKey:@"FacebookPost"];
	//[patronStoreQuery setLimit:20];

    __weak typeof(self) weakSelf = self;
    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
    {
		[weakSelf.activityIndicatorView setHidden:YES];
		[weakSelf.activityIndicator stopAnimating];
		[weakSelf.tableViewController.refreshControl endRefreshing];
		
        if (!error)
        {
			[weakSelf.storeIdArray removeAllObjects];
			
			if(results.count > 0)
			{
				for (PFObject *patronStore in results)
				{
					PFObject *store = [patronStore objectForKey:@"Store"];
					NSString *storeId = [store objectId];
					[weakSelf.sharedData addPatronStore:patronStore forKey:storeId];
					[weakSelf.sharedData addStore:store];
					[weakSelf.storeIdArray addObject:storeId];
				}
			}
			
			[weakSelf refreshTableView];
        }
        else
        {
            NSLog(@"places view: error is %@", error);
			[RepunchUtils showConnectionErrorDialog];
        }
    }];
}

- (void)refreshWhenBackgroundRefreshDisabled
{
	if([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
		[self loadMyPlaces];
	}
}

- (void)sortStoreObjectIdsByPunches
{
	[self.storeIdArray sortUsingComparator:^NSComparisonResult(NSString *objectId1, NSString *objectId2)
    {
		PFObject* patronStore1 = [self.sharedData getPatronStore:objectId1];
		PFObject* patronStore2 = [self.sharedData getPatronStore:objectId2];
		
		NSNumber* n1 = [patronStore1 objectForKey:@"punch_count"];
		NSNumber* n2 = [patronStore2 objectForKey:@"punch_count"];
		return [n2 compare:n1];
	}];
}

#pragma mark - Table view data source

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
    MyPlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyPlacesTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [MyPlacesTableViewCell cell];
    }
	
	NSString *storeId = self.storeIdArray[indexPath.row];
	PFObject *patronStore = [self.sharedData getPatronStore:storeId];
	PFObject *store = [self.sharedData getStore:storeId];
	
    int punches = [[patronStore objectForKey:@"punch_count"] intValue];
    cell.numPunches.text = [NSString stringWithFormat:@"%i %@", punches, (punches == 1) ? @"Punch": @"Punches"];
    cell.storeName.text = [store objectForKey:@"store_name"];
    
    NSArray *rewardsArray = [store objectForKey:@"rewards"];
    
    if (rewardsArray.count > 0) {
        if ([[rewardsArray[0] objectForKey:@"punches"] intValue] <= punches){
            [[cell rewardLabel] setHidden:NO];
            [[cell rewardIcon] setHidden:NO];
        }
		else {
			[[cell rewardLabel] setHidden:YES];
            [[cell rewardIcon] setHidden:YES];
		}
    }
	else {
		[[cell rewardLabel] setHidden:YES];
		[[cell rewardIcon] setHidden:YES];
	}
    
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
	
	NSString *storeId = self.storeIdArray[indexPath.row];
    StoreViewController *storeVC = [[StoreViewController alloc]init];
    storeVC.storeId = storeId;
	storeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		return;
	}
	
    PFFile *existingImageFile = [self.imageDownloadsInProgress objectForKey:indexPath];
	
    if (existingImageFile == nil) {
        [self.imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
				[self.imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				
				UIImage *storeImage = [UIImage imageWithData:data];
				if(storeImage) {
					MyPlacesTableViewCell *cell = (MyPlacesTableViewCell*)[self.tableViewController.tableView cellForRowAtIndexPath:indexPath];
					cell.storeImage.image = storeImage;
					[self.sharedData addStoreImage:storeImage forKey:storeId];
				}
            }
            else {
                NSLog(@"image download failed");
            }
        }];
    }
}

- (void)cancelImageDownload
{
    for(PFFile *imageFile in self.imageDownloadsInProgress) {
        [imageFile cancel];
    }
}

- (void)receiveRefreshNotification:(NSNotification *)notification
{
	NSLog(@"received notificationcenter notification");
	NSString *storeId = [[notification userInfo] objectForKey:@"store_id"];
	
	if(storeId != nil) {
		NSUInteger index = [self.storeIdArray indexOfObject:storeId];
		
		if(index == NSNotFound) {
			NSLog(@"storeId not found, adding it");
			[self.storeIdArray addObject:storeId];
		} else {
			NSLog(@"storeId found, removing it");
			[self.storeIdArray removeObjectAtIndex:index];
		}
	}
	
	[self refreshTableView];
}

- (void)refreshTableView
{
	if(self.storeIdArray.count > 0) {
		[self.emptyMyPlacesLabel setHidden:YES];
	}
	else {
		[self.emptyMyPlacesLabel setHidden:NO];
	}
	
	[self sortStoreObjectIdsByPunches];
	[self.tableViewController.tableView reloadData];
}

/*
// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
	if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.myPlacesTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            MyPlacesTableViewCell *cell = self.entries[indexPath.row];
            
            if (!cell.storeImage.image) // Avoid the app icon download if the app already has an icon
            {
                [self downloadImage:cell forIndexPath:indexPath];
            }
        }
	}
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}
 */

#pragma mark - Toolbar methods

- (void)showPunchCode
{
	/*
	NSString *punchCode = [self.patron objectForKey:@"punch_code"];
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code"
                                                 andMessage:punchCode];
	
	[alert setTitleFont:[UIFont fontWithName:@"Avenir" size:20]];
	[alert setMessageFont:[UIFont fontWithName:@"Avenir-Heavy" size:32]];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
	 */
	
	NSString *punchCode = [self.patron objectForKey:@"punch_code"];
	[RepunchUtils showPunchCode:self.view withPunchCode:punchCode];
}

- (void)openSettings
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	settingsVC.hidesBottomBarWhenPushed = YES;
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}

- (void)openSearch
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
	searchVC.hidesBottomBarWhenPushed = YES;
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:searchVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
	//[self.navigationController pushViewController:searchNavController animated:YES];
}


@end
