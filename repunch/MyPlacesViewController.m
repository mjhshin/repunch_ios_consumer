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
	bgLayer.frame = _toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
    
	int navBarOffset = self.view.frame.size.height - 50; //50 is nav bar height
	self.myPlacesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, navBarOffset) style:UITableViewStylePlain];
    [self.myPlacesTableView setDataSource:self];
    [self.myPlacesTableView setDelegate:self];
    [[self view] addSubview:self.myPlacesTableView];
	
	[self loadMyPlaces];
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)loadMyPlaces
{
    PFRelation *patronStoreRelation = [self.patron relationforKey:@"PatronStores"];
    PFQuery *patronStoreQuery = [patronStoreRelation query];
    [patronStoreQuery includeKey:@"Store"];
	//patronStoreQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;

    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
    {
        if (!error)
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
			//[myPlacesTableView setContentSize:CGSizeMake(320, 105*results.count)];
			[self.myPlacesTableView reloadData];
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
    else {
		NSLog(@" cell reused: ");
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
    {
        //if (self.myPlacesTableView.dragging == NO && self.myPlacesTableView.decelerating == NO)
        PFFile *imageFile = [store objectForKey:@"store_avatar"];
        if(imageFile != nil)
        {
            NSData *data = [self.sharedData getStoreImage:storeId];
            //if(data !=) {
                UIImage *storeImage = [UIImage imageWithData:data];
                if(storeImage == nil)
                {
                    [self downloadImage:imageFile forIndexPath:indexPath withStoreId:storeId];
                } else {
                    cell.storeImage.image = storeImage;
                }
            //}
        }
        // if a download is deferred or in progress, return a placeholder image
        cell.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *storeId = [self.storeIdArray objectAtIndex:indexPath.row];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
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
                MyPlacesTableViewCell *cell = [self.myPlacesTableView cellForRowAtIndexPath:indexPath];
                cell.storeImage.image = [UIImage imageWithData:data];
                [self.imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
                [self.sharedData addStoreImage:data forKey:storeId];
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
