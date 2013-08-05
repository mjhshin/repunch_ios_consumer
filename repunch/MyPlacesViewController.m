//
//  MyPlacesViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MyPlacesViewController.h"
#import "SearchViewController.h"
#import "PlacesDetailViewController.h"
#import "SettingsViewController.h"
#import "SIAlertView.h"
#import "User.h"
#import "Store.h"
#import "Reward.h"
#import "PatronStore.h"
#import "MyPlacesTableViewCell.h"
#import "GlobalToolbar.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "SharedData.h"

@implementation MyPlacesViewController
{
	SharedData* sharedData;
	NSArray* storeObjectIds;
    UITableView* myPlacesTableView;
    PFObject* patron;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [SharedData init];
    
	patron = [sharedData patron];
    
	int navBarOffset = self.view.frame.size.height - 50; //50 is nav bar height
	myPlacesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, navBarOffset) style:UITableViewStylePlain];
    [myPlacesTableView setDataSource:self];
    [myPlacesTableView setDelegate:self];
    [[self view] addSubview:myPlacesTableView];
	
    [self loadMyPlaces];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
    
    //alert to demonstrate how to get the punch code.  will only appear once.
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"showPunchCodeInstructions"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"showPunchCodeInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SIAlertView *punchCodeHelpAlert = [[SIAlertView alloc] initWithTitle:@"A Friendly Tip" andMessage:@"Click on the Repunch logo in order to get your punch code"];
        [punchCodeHelpAlert addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
        [punchCodeHelpAlert show];
    }

    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(setup)
    //                                             name:@"receivedPush"
    //                                           object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(receiveLoadedPics:)
    //                                             name:@"FinishedLoadingPic"
    //                                           object:nil];


}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishedLoadingPic" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadMyPlaces
{	
    PFRelation *patronStoreRelation = [patron relationforKey:@"PatronStores"];
    PFQuery *patronStoreQuery = [patronStoreRelation query];
    [patronStoreQuery includeKey:@"Store"];
	patronStoreQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [patronStoreQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error){
            for (PFObject *patronStore in results) {
				
				PFObject *store = [patronStore objectForKey:@"Store"];
				NSString *storeId = [store objectId];
				[sharedData addPatronStore:patronStore forKey:storeId];
				[sharedData addStore:store forKey:storeId];
            }

			[self sortStoreObjectIdsByPunches];
			//[myPlacesTableView setContentSize:CGSizeMake(320, 105*patronStores.count)];
			[myPlacesTableView reloadData];
        }
        else {
            NSLog(@"places view: error is %@", error);
        }
        
    }];
}

- (void)receiveLoadedPics:(NSNotification *) notification
{
    [myPlacesTableView reloadData];
}

- (void)sortStoreObjectIdsByPunches {
	storeObjectIds = [storeObjectIds sortedArrayUsingComparator:^NSComparisonResult(id objectId1, id objectId2) {
		PFObject* patronStore1 = [sharedData getPatronStore:objectId1];
		PFObject* patronStore2 = [sharedData getPatronStore:objectId2];
		
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
    return [sharedData getPatronStoreCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyPlacesTableViewCell";
    MyPlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MyPlacesTableViewCell" owner:self options:nil] objectAtIndex:0];        
    }
	
	NSString *objectId = [storeObjectIds objectAtIndex:indexPath.row];
	PFObject *patronStore = [sharedData getPatronStore:objectId];
	PFObject *store = [sharedData getStore:objectId];
	
    int punches = [[patronStore objectForKey:@"punch_count"] intValue];
    cell.storeName.text = [store objectForKey:@"store_name"];
    //cell.storeImage.image = [UIImage imageWithData:[store objectForKey:@"store_avatar"]];
	cell.storeImage.image = [UIImage imageNamed:@"placeholder.png"];
	
    cell.numPunches.text = [NSString stringWithFormat:@"%i %@", punches, (punches == 1) ? @"punch": @"punches"];
    
    NSArray *rewardsArray = [store objectForKey:@"rewards"];
    
    if ([rewardsArray count] > 0){
        if (rewardsArray && ([[rewardsArray[0] valueForKey:@"punches"] intValue] <= punches)){
            [[cell rewardLabel] setHidden:FALSE];
            [[cell rewardIcon] setHidden:FALSE];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *objectId = [storeObjectIds objectAtIndex:indexPath.row];
	PFObject *patronStore = [sharedData getPatronStore:objectId];
	PFObject *store = [sharedData getStore:objectId];
	
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.storeObject = store;
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

#pragma mark - Toolber methods

- (IBAction)showPunchCode:(id)sender
{
	NSString *punchCode = [patron objectForKey:@"punch_code"];
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
