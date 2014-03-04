//
//  MyPlacesViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"
#import "RPReloadControl.h"

@interface MyPlacesViewController ()
//@property (nonatomic, strong) UITableViewController *tableViewController;
@property (strong, nonatomic) RPReloadControl *reloadControl;

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
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
    //self.edgesForExtendedLayout = UIRectEdgeNone;

    self.reloadControl = [[RPReloadControl alloc] initWithTableView:self.tableView andImagedNamed:@"app_icon_29x29.png"];

    __weak typeof (self)weakSelf = self;

    self.reloadControl.handler = ^(){
        [weakSelf loadMyPlaces];
    };
	
	[self registerForNotifications];
	[self setupNavigationBar];
	[self loadMyPlaces];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self showHelpViews];
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
	if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"kRPShowInstructions"]])
	{
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowInstructions"];
		[[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"kRPShowPunchCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		NSString *message = [NSString stringWithFormat:
							 @"Your Punch Code is %@\n\nYou can always click on the Repunch logo if you forget.",
							 self.patron.punch_code];
		
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
	
	reach.reachableBlock = ^(Reachability*reach)
	{
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
		[self.reloadControl endRefreshing];
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
    [patronStoreQuery includeKey:@"Store.store_locations"];
	[patronStoreQuery includeKey:@"FacebookPost"];
	//[patronStoreQuery setLimit:20];

    __weak typeof(self) weakSelf = self;
    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
    {
		[weakSelf.activityIndicatorView setHidden:YES];
		[weakSelf.activityIndicator stopAnimating];
		[weakSelf.reloadControl endRefreshing];
		
        if (!error)
        {
			[weakSelf.storeIdArray removeAllObjects];
			
			if(results.count > 0)
			{
				for (RPPatronStore *patronStore in results)
				{
					[weakSelf.sharedData addPatronStore:patronStore forKey:patronStore.Store.objectId];
					[weakSelf.sharedData addStore:patronStore.Store];
					[weakSelf.storeIdArray addObject:patronStore.Store.objectId];
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
		RPPatronStore* patronStore1 = [self.sharedData getPatronStore:objectId1];
		RPPatronStore* patronStore2 = [self.sharedData getPatronStore:objectId2];
		
		NSNumber *punchCount1 = [NSNumber numberWithInteger:patronStore1.punch_count];
		NSNumber *punchCount2 = [NSNumber numberWithInteger:patronStore2.punch_count];
		
		if( [punchCount2 compare:punchCount1] == NSOrderedSame )
		{
			NSNumber *allTimeCount1 = [NSNumber numberWithInteger:patronStore1.all_time_punches];
			NSNumber *allTimeCount2 = [NSNumber numberWithInteger:patronStore2.all_time_punches];
			
			return [allTimeCount2 compare:allTimeCount1];
		}
		else
		{
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
    return [self.storeIdArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyPlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[MyPlacesTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [MyPlacesTableViewCell cell];
    }
	
	NSString *storeId = self.storeIdArray[indexPath.row];
	RPPatronStore *patronStore = [self.sharedData getPatronStore:storeId];
	RPStore *store = [self.sharedData getStore:storeId];
	
	cell.storeName.text = store.store_name;
	cell.numPunches.text = [NSString stringWithFormat:(patronStore.punch_count == 1) ?
										@"%i Punch": @"%i Punches", patronStore.punch_count];
    
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
            UIImage *storeImage = [self.sharedData getThumbnailImage:storeId];
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
	
    PFFile *existingImageFile = self.imageDownloadsInProgress[indexPath];
	
    if (existingImageFile == nil) {
        [self.imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
				[self.imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				
				UIImage *storeImage = [UIImage imageWithData:data];
				if(storeImage) {
					MyPlacesTableViewCell *cell = (MyPlacesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
					//cell.storeImage.image = storeImage;
					[cell.storeImage setImageWithAnimation:storeImage];
					[self.sharedData addThumbnailImage:storeImage forKey:storeId];
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
	NSString *storeId = notification.userInfo[@"store_id"];
	
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
	[RepunchUtils showPunchCode:self.patron.punch_code];
}

- (void)openSettings
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
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
}


@end
