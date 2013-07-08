//
//  PlacesViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesSearchViewController.h"
#import "PlacesDetailViewController.h"
#import "SettingsViewController.h"
#import "SIAlertView.h"
#import "User.h"
#import "Store.h"
#import "Reward.h"
#import "PatronStore.h"
#import "SavedStoreCell.h"
#import "GlobalToolbar.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

//JUST FOR MY OWN SANITY, what's goingon:
//on viewdidload: set up UI, meaning global toolbar, tableview
//on viewwillappear: set up model+data sources, meaning all saved_stores

//settings button goes to settings page
//search button goes to search page
//clicking on table cell goes to place detail view

@implementation PlacesViewController{
    User *localUser;
    GlobalToolbar *globalToolbar;
    NSMutableArray *savedStores;
    UITableView *savedStoresTable;
    PFObject *patronObject;
}

- (void)setup {

    //load all stores from local data store
    //NSMutableSet *patronStores = [localUser mutableSetValueForKey:@"saved_stores"];
    //NSMutableSet *enumerationCopy = [NSSet setWithArray:savedStores];
    
    /*
     //sync with view's set of stores
     for (id item in patronStores) {
     if (![enumerationCopy member:item]) {
     [savedStores addObject:item];
     }
     }*/

    
    savedStores = [[[localUser mutableSetValueForKey:@"saved_stores"] allObjects] mutableCopy];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"punch_count"  ascending:NO];
    savedStores = [[savedStores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];

    [savedStoresTable reloadData];
    
    //NSLog(@"here are stores in local user %@: %@", localUser.username, [[patronStores valueForKey:@"store"] valueForKey:@"store_name"]);
    NSLog(@"user:%@", [localUser username]);
    NSLog(@"patron: %@", [localUser patronId]);
    NSLog(@"here are saved stores: %@", [[savedStores valueForKey:@"store"] valueForKey:@"store_name"]);
    
    PFRelation *patronStoreRelation = [patronObject relationforKey:@"PatronStores"];
    PFQuery *storeQuery = [patronStoreRelation query];
    [storeQuery includeKey:@"Store"];
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedPatronStores, NSError *error) {
        for (PFObject *fetchedPatronStore in fetchedPatronStores){
            BOOL isAlreadyInList = [localUser alreadyHasStoreSaved:[[fetchedPatronStore valueForKey:@"Store"] objectId]];

            //NSLog(@"%@ %@ already is list", [[fetchedPatronStore valueForKey:@"Store"] valueForKey:@"store_name"], isAlreadyInList?@"is":@"IS NOT");
            if (isAlreadyInList){
                PatronStore *storeToBeUpdated = [PatronStore MR_findFirstByAttribute:@"store_id" withValue:[[fetchedPatronStore valueForKey:@"Store"] objectId]];
                [storeToBeUpdated updateLocalEntityWithParseObject:fetchedPatronStore];
                [savedStoresTable reloadData];
            }
            
            if (!isAlreadyInList){
                PatronStore *newPatronStore = [PatronStore MR_createEntity];
                Store *newSavedStore = [Store MR_findFirstByAttribute:@"objectId" withValue:[[fetchedPatronStore valueForKey:@"Store"] objectId]];
                if (!newSavedStore){
                    newSavedStore = [Store MR_createEntity];
                    [newSavedStore setFromParseObject:[fetchedPatronStore valueForKey:@"Store"]];
                }
                
                [newPatronStore setFromPatronObject:fetchedPatronStore andStoreEntity:newSavedStore andUserEntity:localUser];
                [savedStores addObject:newPatronStore];
                savedStores = [[savedStores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];
                [savedStoresTable reloadData];
                

            }
        }
        
    }];
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
    //spinner to run while fetches happen
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 260);
    spinner.color = [UIColor blackColor];
    [[self view] addSubview:spinner];
    [spinner startAnimating];

    globalToolbar = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [(GlobalToolbar *)globalToolbar setToolbarDelegate:self];
    [self.view addSubview:globalToolbar];
    
    savedStores = [[NSMutableArray alloc] init];
    savedStoresTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 450) style:UITableViewStylePlain];
    [savedStoresTable setDataSource:self];
    [savedStoresTable setDelegate:self];
    [[self view] addSubview:savedStoresTable];



}

- (void)viewWillAppear:(BOOL)animated {
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];
    patronObject = [(AppDelegate *)[[UIApplication sharedApplication] delegate] patronObject];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadedPics:)
                                                 name:@"FinishedLoadingPic"
                                               object:nil];


    [super viewWillAppear:animated];
    [self setup];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishedLoadingPic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)receiveLoadedPics:(NSNotification *) notification{
    [savedStoresTable reloadData];
}


#pragma mark - Global Toolbar Delegate

- (void) openSettings
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingsVC.modalDelegate = self;
    settingsVC.userName = [localUser fullName];
    [self presentViewController:settingsVC animated:YES completion:NULL];

}


- (void) openSearch
{
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

-(void)showPunchCode{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code" andMessage:[NSString stringWithFormat:@"Your punch code is %@", [localUser punch_code]]];
    [alert addButtonWithTitle:@"Cool" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        //nothing happens
    }];
    [alert show];
}

#pragma mark - Modal View Delegate

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [savedStores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavedStoreCell";
    SavedStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SavedStoreCell" owner:self options:nil]objectAtIndex:0];        
    }
    int punches = [[[savedStores objectAtIndex:indexPath.row]valueForKey:@"punch_count"] intValue];
    cell.storeName.text = [[[savedStores objectAtIndex:indexPath.row] store] valueForKey:@"store_name"];
    cell.storePic.image = [UIImage imageWithData:[[[savedStores objectAtIndex:indexPath.row] store] valueForKey:@"store_avatar"]];
    cell.numberPuches.text = [NSString stringWithFormat:@"%i %@", punches, (punches == 1)?@"punch": @"punches"];
    
    Store *storeForThisCell = [[savedStores objectAtIndex:indexPath.row] store];
    NSArray *rewardsArray = [[storeForThisCell mutableSetValueForKey:@"rewards"] allObjects];
    
    if ([rewardsArray count]>0){
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"punches"  ascending:YES];
        rewardsArray = [rewardsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

        if (rewardsArray && ([[rewardsArray[0] valueForKey:@"punches"] intValue]<=punches)){
            [[cell rewardLabel] setHidden:FALSE];
            [[cell rewardPic] setHidden:FALSE];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [[savedStores objectAtIndex:indexPath.row] store];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = YES;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}



@end
