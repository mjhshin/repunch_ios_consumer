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
#import "User.h"
#import "Store.h"
#import "PatronStore.h"
#import "StoreCell.h"
#import "GlobalToolbar.h"
#import <Parse/Parse.h>

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

}

- (void)setup {

    //load all stores from local data store
    NSMutableSet *patronStores = [localUser mutableSetValueForKey:@"saved_stores"];
    
    for (PatronStore *patronStore in patronStores){
        BOOL alreadyInList = FALSE;
        for (id savedStore in savedStores){
            if ([[savedStore objectId] isEqualToString:[patronStore.store objectId]]){
                alreadyInList = TRUE;
                break;
            }
            if(!alreadyInList){
                [savedStores addObject:patronStore.store];
                [savedStoresTable reloadData];
            }
        }
    }
    
    NSLog(@"PLACES VIEW: before network %@", patronStores);
    
    //then get them from the network
    //get patron object from user id
    PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
    [patronQuery getObjectInBackgroundWithId:localUser.patronId block:^(PFObject *patronObject, NSError *error) {
        if (!error){
            
            //fetch all patron objects
            PFRelation *patronStoreRelation = [patronObject relationforKey:@"PatronStores"];
            [[patronStoreRelation query] findObjectsInBackgroundWithBlock:^(NSArray *patronStores, NSError *error) {
                if (error) {
                    NSLog(@"there was an error: %@", error);
                } else {
                    //for each patron store, check that it's not already in list. if not, add to table view.
                    for (id patronStore in patronStores){
                        PFObject *store = [patronStore valueForKey:@"Store"];
                        [store fetchIfNeededInBackgroundWithBlock:^(PFObject *storeObject, NSError *error) {
                            if (!error){
                                
                                BOOL alreadyInList = FALSE;
                                for (id savedStore in savedStores){
                                    if ([[savedStore objectId] isEqualToString:[storeObject objectId]]){
                                        alreadyInList = TRUE;
                                        break;
                                    }
                                }
                                if (!alreadyInList){
                                    Store *newSavedStore = [Store MR_findFirstByAttribute:@"objectId" withValue:[store objectId]];
                                    if (!newSavedStore){
                                        newSavedStore = [Store MR_createEntity];
                                        [newSavedStore setFromParseObject:store];
                                    }
                                    [savedStores addObject:newSavedStore];
                                    [savedStoresTable reloadData];
                                    
                                    NSLog(@"PLACES VIEW: before network %@", patronStores);

                                }
                                
                            }
                            else NSLog(@"there was an error: %@", error);
                        }]; //end get store from patronstore
                    } //end looping through patronstores
                } //end if no error condition
            }]; //end get patron object with user's patron id
        } else NSLog(@"Error is %@", error);
        
    }]; //end patron query

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

    
    localUser = [User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
    if (localUser == nil){
        localUser = [User MR_createEntity];
        PFObject *patron = [[PFUser currentUser] objectForKey:@"Patron"];
        [patron fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedPatron, NSError *error) {
            [spinner stopAnimating];
            if (!error){
                [localUser setFromParseUserObject:[PFUser currentUser] andPatronObject:fetchedPatron];
                [self setup];
            } else NSLog(@"Error is %@", error);
        }];
    } else [self setup];
    
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
    [super viewWillAppear:animated];
    if (!localUser){
        [self setup];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Unregister from notifications and KVO here (balancing viewWillAppear:).
    // Stop timers.
    // This is a good place to tidy things up, free memory, save things to
    // the model, etc.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Global Toolbar Delegate

- (void) openSettings
{
}


- (void) openSearch
{
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

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
    static NSString *CellIdentifier = @"StoreCell";
    StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreCell" owner:self options:nil]objectAtIndex:0];        
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    cell.storeNameLabel.text = [[savedStores objectAtIndex:indexPath.row] valueForKey:@"store_name"];
    cell.storeImageLabel.image = [UIImage imageWithData:[[savedStores objectAtIndex:indexPath.row] valueForKey:@"store_avatar"]];
    
    NSLog(@"saved stores are:%@ with punch_count:%@", [savedStores valueForKey:@"store_name"], [savedPatronStores valueForKey:@"punch_count"]);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [savedStores objectAtIndex:indexPath.row];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = YES;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
    
}

//this method doesn't work when there's an image view in the cell for some reason....
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [savedStores objectAtIndex:indexPath.row];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = NO;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}



@end
