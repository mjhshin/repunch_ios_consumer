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
#import "CoreDataStore.h"


@implementation PlacesViewController{
    User *localUser;
    GlobalToolbar *globalToolbar;
    NSMutableArray *savedStores;
    UITableView *savedStoresTable;
    PFObject *patronObject;
    BOOL searchLoaded;
}

- (void)setup {
    //get all local store entities and sort them by number of punches
    savedStores = [[[localUser mutableSetValueForKey:@"saved_stores"] allObjects] mutableCopy];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"punch_count"  ascending:NO];
    savedStores = [[savedStores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];

    [savedStoresTable reloadData];
    
    NSLog(@"user:%@", [localUser username]);
    NSLog(@"patron: %@", [localUser patronId]);
    NSLog(@"here are saved stores: %@", [[savedStores valueForKey:@"store"] valueForKey:@"store_name"]);
 
    PFRelation *patronStoreRelation = [patronObject relationforKey:@"PatronStores"];
    PFQuery *storeQuery = [patronStoreRelation query];
    [storeQuery includeKey:@"Store"];
    
    //get saved stores from parse backend
    [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedPatronStores, NSError *error) {
        if (!error){
            for (PFObject *fetchedPatronStore in fetchedPatronStores){
            
                //check if saved store is already in local store's saved list
                BOOL isAlreadyInList = [localUser alreadyHasStoreSaved:[[fetchedPatronStore valueForKey:@"Store"] objectId]];

                NSLog(@"%@ %@ already is list", [[fetchedPatronStore valueForKey:@"Store"] valueForKey:@"store_name"], isAlreadyInList?@"is":@"IS NOT");
                
                if (isAlreadyInList){
                    PatronStore *storeToBeUpdated = [PatronStore MR_findFirstByAttribute:@"store_id" withValue:[[fetchedPatronStore valueForKey:@"Store"] objectId]];
                    [storeToBeUpdated updateLocalEntityWithParseObject:fetchedPatronStore];
                }
                
                if (!isAlreadyInList){
                    
                    Store *newSavedStore = [Store MR_findFirstByAttribute:@"objectId" withValue:[[fetchedPatronStore valueForKey:@"Store"] objectId]];
                    if (!newSavedStore){
                        newSavedStore = [Store MR_createEntity];
                        [newSavedStore setFromParseObject:[fetchedPatronStore valueForKey:@"Store"]];
                    }
                    
                    PatronStore *newPatronStore = [PatronStore MR_createEntity];
                    [newPatronStore setFromPatronObject:patronObject andStoreEntity:newSavedStore andUserEntity:localUser andPatronStore:fetchedPatronStore];
                    [savedStores addObject:newPatronStore];
                    [localUser addSaved_storesObject:newPatronStore];
                    [CoreDataStore saveContext];
                }
                
                [savedStoresTable setFrame:CGRectMake(0, 51, 320, self.view.frame.size.height - 51)]; //49 is tab bar height
                [savedStoresTable setContentSize:CGSizeMake(320, 105*savedStores.count)];
                savedStores = [[savedStores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];
                [savedStoresTable reloadData];
                
            }
            
        }
        else {
            NSLog(@"places view: error is %@", error);
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
    
    savedStores = [[NSMutableArray alloc] init];
    savedStoresTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 51, 320, 0) style:UITableViewStylePlain];
    [savedStoresTable setDataSource:self];
    [savedStoresTable setDelegate:self];
    
    [[self view] addSubview:savedStoresTable];
    
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];
    patronObject = [(AppDelegate *)[[UIApplication sharedApplication] delegate] patronObject];

    [self setup];

    searchLoaded = false;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //alert to demonstrate how to get the punch code.  will only appear once.
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"showPunchCodeInstructions"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"showPunchCodeInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SIAlertView *punchCodeInstructionsAlert = [[SIAlertView alloc] initWithTitle:@"A Friendly Tip" andMessage:@"Click on the Repunch logo in order to get your punch code"];
        [punchCodeInstructionsAlert addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
        [punchCodeInstructionsAlert show];
        
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadedPics:)
                                                 name:@"FinishedLoadingPic"
                                               object:nil];


}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishedLoadingPic" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)receiveLoadedPics:(NSNotification *) notification{
    [savedStoresTable reloadData];
}



#pragma mark - Modal View Delegate

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didDismissPresentedViewControllerWithCompletionCode:(NSString *)dismissString {
    if ([dismissString isEqualToString:@"logout"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate logout];
        }];
        
    }

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

#pragma mark - Toolber methods

- (IBAction)openSettings:(id)sender {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingsVC.modalDelegate = self;
    settingsVC.userName = [localUser fullName];
    [self presentViewController:settingsVC animated:YES completion:NULL];

}

- (IBAction)showPunchCode:(id)sender {
    
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code" andMessage:[NSString stringWithFormat:@"Your punch code is %@", [localUser punch_code]]];
    [alert addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];

    
}

- (IBAction)openSearch:(id)sender {
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    placesSearchVC.downloadFromNetwork = !searchLoaded;
    if (!searchLoaded) searchLoaded = TRUE;
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
    
    

}
@end
