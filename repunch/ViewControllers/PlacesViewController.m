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
    // Non-UI initialization goes here. It will only ever be called once.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    localUser = [User MR_findFirstByAttribute:@"username" withValue:[[PFUser currentUser] username]];
        
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
    
    //get patron object from id
    PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
    [patronQuery getObjectInBackgroundWithId:localUser.patronId block:^(PFObject *patronObject, NSError *error) {
        if (!error){
            //get all patron objects
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
                                    [savedStores addObject:storeObject];
                                    [savedStoresTable reloadData];
                                }


                            }
                            else NSLog(@"there was an error: %@", error);
                        }]; //end get store from patronstore
                    } //end looping through patronstores
                } //end if no error condition
            }]; //end get patron object with user's patron id
        } else NSLog(@"Error is %@", error);
    }];
    


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
    [placesSearchVC setup];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[savedStores objectAtIndex:indexPath.row] valueForKey:@"store_name"];
    [cell.textLabel setNumberOfLines:3];
    [cell.textLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:14]];
    
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_reward-list-gradient"]]];
    
    NSLog(@"stores saved are: %@", [savedStores valueForKey:@"store_name"]);

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [savedStores objectAtIndex:indexPath.row];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = YES;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];
}



@end
