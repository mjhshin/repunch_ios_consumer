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
    [savedStoresTable reloadData];
    
    //NSLog(@"here are stores in local user %@: %@", localUser.username, [[patronStores valueForKey:@"store"] valueForKey:@"store_name"]);
    NSLog(@"here are saved stores: %@", [[savedStores valueForKey:@"store"] valueForKey:@"store_name"]);
    
    PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
    [patronQuery getObjectInBackgroundWithId:localUser.patronId block:^(PFObject *fetchedPatron, NSError *error) {
        PFRelation *patronStoreRelation = [fetchedPatron relationforKey:@"PatronStores"];
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
                    [savedStoresTable reloadData];
                }
            }
            
        }];

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
    } else if ([localUser.patronId length]>0) [self setup];
    
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
    if ([localUser.patronId length]>0){
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
    NSNumber *punches = [[savedStores objectAtIndex:indexPath.row]valueForKey:@"punch_count"];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    cell.storeNameLabel.text = [[[savedStores objectAtIndex:indexPath.row] store] valueForKey:@"store_name"];
    cell.storeImageLabel.image = [UIImage imageWithData:[[[savedStores objectAtIndex:indexPath.row] store] valueForKey:@"store_avatar"]];
    cell.storeAddressLabel.text = [NSString stringWithFormat:@"%@ %@", punches, ([punches isEqualToNumber:[NSNumber numberWithInt:1]])?@"punch": @"punches"];
        
    return cell;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [[savedStores objectAtIndex:indexPath.row] store];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = YES;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
    
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
