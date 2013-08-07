//
//  MyPlacesViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"

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
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
    
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	int toolBarHeight = self.toolbar.frame.size.height;
	int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	int tableViewHeight = screenHeight - toolBarHeight;
	
	self.myPlacesTableView = [[UITableView alloc]
							  initWithFrame:CGRectMake(0, toolBarHeight, screenWidth, tableViewHeight - tabBarHeight)
									  style:UITableViewStylePlain];
	
    [self.myPlacesTableView setDataSource:self];
    [self.myPlacesTableView setDelegate:self];
    [self.view addSubview:self.myPlacesTableView];
	[self.myPlacesTableView setHidden:TRUE];
	
	CGFloat xCenter = screenWidth/2;
	CGFloat yCenter = screenHeight/2;
	CGFloat xOffset = self.activityIndicatorView.frame.size.width/2;
	CGFloat yOffset = self.activityIndicatorView.frame.size.height/2;
	CGRect frame = self.activityIndicatorView.frame;
	frame.origin = CGPointMake(xCenter - xOffset, yCenter - yOffset);
	self.activityIndicatorView.frame = frame;
	
	[self loadMyPlaces];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //alert to demonstrate how to get the punch code.  will only appear once.
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"showPunchCodeInstructions"]])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"showPunchCodeInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SIAlertView *punchCodeHelpAlert = [[SIAlertView alloc] initWithTitle:@"A Friendly Tip" andMessage:@"Click on the Repunch logo in order to get your punch code"];
        [punchCodeHelpAlert addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
        [punchCodeHelpAlert show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending image downloads
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)loadMyPlaces
{
	[self.activityIndicatorView setHidden:FALSE];
	[self.activityIndicator startAnimating];
	[self.myPlacesTableView setHidden:TRUE];
	
    PFRelation *patronStoreRelation = [self.patron relationforKey:@"PatronStores"];
    PFQuery *patronStoreQuery = [patronStoreRelation query];
    [patronStoreQuery includeKey:@"Store"];
	[patronStoreQuery includeKey:@"FacebookPost"];
	[patronStoreQuery setLimit:20];
	//TODO: paginate!!!

    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
    {
		[self.activityIndicatorView setHidden:TRUE];
		[self.activityIndicator stopAnimating];
		
        if (!error)
        {
			if(results.count > 0)
			{
				for (PFObject *patronStore in results)
				{
					PFObject *store = [patronStore objectForKey:@"Store"];
					NSString *storeId = [store objectId];
					[self.sharedData addPatronStore:patronStore forKey:storeId];
					[self.sharedData addStore:store];
					[self.storeIdArray addObject:storeId];
				}

				[self sortStoreObjectIdsByPunches];
				[self.myPlacesTableView reloadData];
				[self.myPlacesTableView setHidden:FALSE];
			}
			else
			{
				//TODO: show empty my places label
			}
        }
        else
        {
            NSLog(@"places view: error is %@", error);
        }
        
    }];
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
	
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
	PFObject *patronStore = [self.sharedData getPatronStore:storeId];
	PFObject *store = [self.sharedData getStore:storeId];
	
    int punches = [[patronStore objectForKey:@"punch_count"] intValue];
    cell.numPunches.text = [NSString stringWithFormat:@"%i %@", punches, (punches == 1) ? @"punch": @"punches"];
    cell.storeName.text = [store objectForKey:@"store_name"];
    
    NSArray *rewardsArray = [store objectForKey:@"rewards"];
    
    if ([rewardsArray count] > 0)
    {
        if (rewardsArray && ([[rewardsArray[0] valueForKey:@"punches"] intValue] <= punches))
        {
            [[cell rewardLabel] setHidden:FALSE];
            [[cell rewardIcon] setHidden:FALSE];
        }
    }
    
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
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
    StoreViewController *placesDetailVC = [[StoreViewController alloc]init];
    placesDetailVC.storeId = storeId;
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
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
                MyPlacesTableViewCell *cell = [self.myPlacesTableView cellForRowAtIndexPath:indexPath]; //TODO: this warning
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
            MyPlacesTableViewCell *cell = [self.entries objectAtIndex:indexPath.row];
            
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

#pragma mark - Toolber methods

- (IBAction)showPunchCode:(id)sender
{
	NSString *punchCode = [self.patron objectForKey:@"punch_code"];
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code"
                                                 andMessage:[NSString stringWithFormat:@"Your punch code is %@", punchCode]];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];
}

- (IBAction)openSettings:(id)sender
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self presentViewController:settingsVC animated:YES completion:NULL];
}

- (IBAction)openSearch:(id)sender
{
    SearchViewController *placesSearchVC = [[SearchViewController alloc]init];
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

@end
