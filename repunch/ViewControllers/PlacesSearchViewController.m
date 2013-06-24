//
//  PlacesSearchViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PlacesSearchViewController.h"
#import "PlacesDetailViewController.h"

#import "Store.h"
#import "User.h"
#import "StoreCell.h"

#import <Parse/Parse.h>

@implementation PlacesSearchViewController{
    __block NSMutableArray *storeList;
    UIToolbar *globalToolbar;
    PFGeoPoint *userLocation;
    UITableView *searchTable;
    User *localUser;

}

//set up data model
- (void)setup {
    //get all locally stored store entitires and set that to be storeList
    storeList = [[Store MR_findAll] mutableCopy];

    
    //update list with stores from cache+network
    //will only add new stores, will not check/change any information for locally stored stores
    if ([CLLocationManager locationServicesEnabled]) {
        //get user location
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
            userLocation = geoPoint;
            
            //only get ten closest stores
            PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
            storeQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            storeQuery.maxCacheAge = 60 * 60 * 24; //clears cache every 24 hours
            [storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
            storeQuery.limit = 10;

            [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedStores, NSError *error){
                for (PFObject *store in fetchedStores){
                    
                    BOOL storeIsInList = FALSE;
                    
                    //check if store is in list
                    for (id localStore in storeList){
                        if ([[localStore valueForKey:@"objectId"] isEqualToString:[store objectId]]){
                            storeIsInList = TRUE;
                            break;
                        }
                    }
                    
                    //if not, add it + store on disk
                     if(!storeIsInList){
                         Store *newStore = [Store MR_createEntity];
                         [newStore setFromParseObject:store];
                         [storeList addObject:newStore];
                         [searchTable reloadData];

                     }//end if stores is not in list
                    
                    
                }//end for all fetched loop
                
            }]; //end get stores
        }]; //end get user location
    }

}


//set up UI configuration
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Programmatically changing global toolbar
    //FROM HERE...
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissPresentedViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UILabel *searchTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 46)];
    [searchTitle setText:@"Search"];
    [searchTitle setFont:[UIFont boldSystemFontOfSize:20]];
    [searchTitle setTextColor:[UIColor whiteColor]];
    [searchTitle setBackgroundColor:[UIColor clearColor]];
    [searchTitle setShadowOffset:CGSizeMake(0, -1)];
    [searchTitle setShadowColor:[UIColor blackColor]];
    [searchTitle sizeToFit];
    
    UIBarButtonItem *searchTitleItem = [[UIBarButtonItem alloc] initWithCustomView:searchTitle];
    
    globalToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [globalToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [globalToolbar setItems:[NSArray arrayWithObjects:closeButtonItem, flex, searchTitleItem, flex2, nil]];
    // ... TO HERE, this is allll just programming the toolbar.
    
    [self.view addSubview:globalToolbar];
    
    
    storeList = [[NSMutableArray alloc] init];
    
    searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 450) style:UITableViewStylePlain];
    [searchTable setDataSource:self];
    [searchTable setDelegate:self];
    [[self view] addSubview:searchTable];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadedPics:)
                                                 name:@"FinishedLoadingPic"
                                               object:nil];
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishedLoadingPic" object:nil];
}


-(void)receiveLoadedPics:(NSNotification *) notification{
    [searchTable reloadData];
}

- (void)dismissPresentedViewController{
    [[self modalDelegate] didDismissPresentedViewController];
}

- (void)didDismissPresentedViewController{
    [self dismissPresentedViewController];
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
     return [storeList count];
 }

 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     static NSString *CellIdentifier = @"StoreCell";
      StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         //cell = [[StoreCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
         cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreCell" owner:self options:nil]objectAtIndex:0];

     }
    
     //this might be useful later
     /*
      PFGeoPoint *storeLocation = [store objectForKey:@"coordinates"];
      double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
      NSLog(@"distance is %g", distanceToStore);
      */
     
     NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", [[storeList objectAtIndex:indexPath.row] valueForKey:@"street"], [[storeList objectAtIndex:indexPath.row] valueForKey:@"city"], [[storeList objectAtIndex:indexPath.row] valueForKey:@"state"], [[storeList objectAtIndex:indexPath.row] valueForKey:@"zip"]];
     
     [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
     cell.storeAddressLabel.text = addressString;
     cell.storeNameLabel.text = [[storeList objectAtIndex:indexPath.row] valueForKey:@"store_name"];
     cell.storeImageLabel.image = [UIImage imageWithData:[[storeList objectAtIndex:indexPath.row] valueForKey:@"store_avatar"]];
      
     return cell;

 }

#pragma mark - Table View delegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
    placesDetailVC.modalDelegate = self;
    placesDetailVC.storeObject = [storeList objectAtIndex:indexPath.row];
    placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    placesDetailVC.isSavedStore = NO;
    
    [self presentViewController:placesDetailVC animated:YES completion:NULL];

}

//this method doesn't work when there's an image view in the cell for some reason.... wait no, why is it suddenly working!?
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
     placesDetailVC.modalDelegate = self;
     placesDetailVC.storeObject = [storeList objectAtIndex:indexPath.row];
     placesDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     placesDetailVC.isSavedStore = NO;
     
     [self presentViewController:placesDetailVC animated:YES completion:NULL];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}




@end
