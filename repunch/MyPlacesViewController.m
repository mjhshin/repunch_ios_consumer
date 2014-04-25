//
//  MyPlacesViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"
#import "SearchViewController.h"
#import "RPPullToRefreshView.h"

@implementation MyPlacesViewController
{
	DataManager *dataManager;
	RPPatron *patron;
	NSMutableArray *storeIdArray;
	NSMutableDictionary *imageDownloadsInProgress;
	BOOL loadInProgress;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	dataManager = [DataManager getSharedInstance];
	patron = [dataManager patron];
	storeIdArray = [NSMutableArray array];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
	loadInProgress = NO;
	
	[self registerForNotifications];
	[self setupNavigationBar];
	[self loadMyPlaces];

	__weak typeof(self) weakSelf = self;
	[self.tableView addPullToRefreshActionHandler:^{
		[weakSelf loadMyPlaces];
	}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showHelpViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	NSLog(@"My Places didReceiveMemoryWarning");
    
    // terminate all pending image downloads
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [imageDownloadsInProgress removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showHelpViews
{
	if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"kRPShowInstructions"]])
	{
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowInstructions"];
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowPunchCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		NSString *message = [NSString stringWithFormat:
							 @"Your Punch Code is %@\n\nYou can always click on the Repunch logo if you forget.",
							 patron.punch_code];
		
		[RepunchUtils showDialogWithTitle:@"Hello!"
							  withMessage:message];
    }
	else if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"kRPShowPunchCode"]])
	{
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowPunchCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		[self showPunchCode];
    }
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receiveRefreshNotification:)
												 name:kNotificationAddOrRemoveStore
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receiveRefreshNotification:)
												 name:kNotificationPunch
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:kNotificationRedeem
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshTableView)
												 name:kNotificationFacebookPost
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshWhenBackgroundRefreshDisabled)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
	
	__weak typeof(self) weakSelf = self;
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	reach.reachableBlock = ^(Reachability *reach) {
		if(storeIdArray.count == 0) {
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
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_settings"]
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(openSettings)];
	
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_search"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(openSearch)];
	
	UIButton *punchCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
	[punchCodeButton setImage:[UIImage imageNamed:@"nav_repunch_logo"] forState:UIControlStateNormal];
	[punchCodeButton addTarget:self action:@selector(showPunchCode) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.leftBarButtonItem = settingsButton;
	self.navigationItem.rightBarButtonItem = searchButton;
	self.navigationItem.titleView = punchCodeButton;
}

- (void)loadMyPlaces
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[self.tableView stopRefreshAnimation];
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(loadInProgress) {
		return;
	}
	
	loadInProgress = YES;
	
	if(storeIdArray.count == 0) {
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
	}
	self.emptyMyPlacesLabel.hidden = YES;
	
    PFRelation *patronStoreRelation = [patron relationforKey:@"PatronStores"];
    PFQuery *patronStoreQuery = [patronStoreRelation query];
    [patronStoreQuery includeKey:@"Store.store_locations"];
	[patronStoreQuery includeKey:@"FacebookPost"];
	//[patronStoreQuery setLimit:20];

    __weak typeof(self) weakSelf = self;
    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		
		[weakSelf.activityIndicatorView setHidden:YES];
		[weakSelf.activityIndicator stopAnimating];
		[self.tableView stopRefreshAnimation];
		
		loadInProgress = NO;
		
        if (!error)
        {
			[storeIdArray removeAllObjects];
			
			if(results.count > 0)
			{
				for (RPPatronStore *patronStore in results)
				{
					[dataManager addPatronStore:patronStore forKey:patronStore.Store.objectId];
					[dataManager addStore:patronStore.Store];
					[storeIdArray addObject:patronStore.Store.objectId];
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
	[storeIdArray sortUsingComparator:^NSComparisonResult(NSString *objectId1, NSString *objectId2) {
		
		RPPatronStore* patronStore1 = [dataManager getPatronStore:objectId1];
		RPPatronStore* patronStore2 = [dataManager getPatronStore:objectId2];
		
		NSNumber *punchCount1 = [NSNumber numberWithInteger:patronStore1.punch_count];
		NSNumber *punchCount2 = [NSNumber numberWithInteger:patronStore2.punch_count];
		
		if( [punchCount2 compare:punchCount1] == NSOrderedSame ) {
			NSNumber *allTimeCount1 = [NSNumber numberWithInteger:patronStore1.all_time_punches];
			NSNumber *allTimeCount2 = [NSNumber numberWithInteger:patronStore2.all_time_punches];
			
			return [allTimeCount2 compare:allTimeCount1];
		}
		else {
			return [punchCount2 compare:punchCount1];
		}
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return storeIdArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyPlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyPlacesTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [MyPlacesTableViewCell cell];
    }
	
	NSString *storeId = storeIdArray[indexPath.row];
	RPPatronStore *patronStore = [dataManager getPatronStore:storeId];
	RPStore *store = [dataManager getStore:storeId];
	
	cell.storeName.text = store.store_name;
	cell.numPunches.text = [NSString stringWithFormat:(patronStore.punch_count == 1) ?
										@"%d Punch": @"%d Punches", patronStore.punch_count];
    
    if (store.rewards.count > 0) {
        if ([store.rewards[0][@"punches"] intValue] <= patronStore.punch_count) {
            [cell.rewardLabel setHidden:NO];
            [cell.rewardIcon setHidden:NO];
        }
		else {
			[cell.rewardLabel setHidden:YES];
            [cell.rewardIcon setHidden:YES];
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
		if( !IS_NIL(store.thumbnail_image) )
        {
            UIImage *storeImage = [dataManager getThumbnailImage:storeId];
			if(storeImage == nil)
			{
				cell.storeImage.image = [UIImage imageNamed:@"placeholder_thumbnail_image"];
				[self downloadImage:store.thumbnail_image forIndexPath:indexPath withStoreId:storeId];
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
	
	StoreViewController *storeVC = [[StoreViewController alloc]init];
    storeVC.storeId = storeIdArray[indexPath.row];
	storeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		return;
	}
	
    PFFile *existingImageFile = imageDownloadsInProgress[indexPath];
	
    if (existingImageFile == nil) {
        [imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			
            if (!error) {
				[imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				
				UIImage *storeImage = [UIImage imageWithData:data];
				if(storeImage) {
					MyPlacesTableViewCell *cell = (MyPlacesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
					//cell.storeImage.image = storeImage;
					[cell.storeImage setImageWithAnimation:storeImage];
					[dataManager addThumbnailImage:storeImage forKey:storeId];
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
    for(PFFile *imageFile in imageDownloadsInProgress) {
        [imageFile cancel];
    }
}

- (void)receiveRefreshNotification:(NSNotification *)notification
{
	//NSLog(@"received notificationcenter notification");
	NSString *storeId = notification.userInfo[@"store_id"];
	
	if(storeId != nil) {
		NSUInteger index = [storeIdArray indexOfObject:storeId];
		
		if(index == NSNotFound) {
			NSLog(@"storeId not found, adding it");
			[storeIdArray addObject:storeId];
		} else {
			NSLog(@"storeId found, removing it");
			[storeIdArray removeObjectAtIndex:index];
		}
	}
	
	[self refreshTableView];
}

- (void)refreshTableView
{
	if(storeIdArray.count > 0) {
		[self.emptyMyPlacesLabel setHidden:YES];
	}
	else {
		[self.emptyMyPlacesLabel setHidden:NO];
	}
	
	[self sortStoreObjectIdsByPunches];
	[self.tableView reloadData];
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
	[RepunchUtils showPunchCode:patron.punch_code];
}

- (void)openSettings
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	RPNavigationController *searchNavController = [[RPNavigationController alloc] initWithRootViewController:settingsVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}

- (void)openSearch
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
	searchVC.hidesBottomBarWhenPushed = YES;
	RPNavigationController *searchNavController = [[RPNavigationController alloc] initWithRootViewController:searchVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}


@end
