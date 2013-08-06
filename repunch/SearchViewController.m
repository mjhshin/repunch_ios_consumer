//
//  PlacesSearchViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchViewController.h"
#import "PlacesDetailViewController.h"

#import "StoreCell.h"
#import "GradientBackground.h"

#import <Parse/Parse.h>
#import "AppDelegate.h"

@implementation SearchViewController
{
    __block NSMutableArray *storeList;
    UIToolbar *globalToolbar;
    PFGeoPoint *userLocation;
    UITableView *searchTable;
}

- (IBAction)closeView:(id)sender {
    [self didDismissPresentedViewController];
}

//set up data model
- (void)setup
{
	/*
    //get all locally stored store entities and set that to be storeList
    storeList = [[Store MR_findAll] mutableCopy];
    
        //update list with stores from cache+network
        //will only add new stores, will not check/change any information for locally stored stores
        if ([CLLocationManager locationServicesEnabled]) {
            //get user location
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
                userLocation = geoPoint;
                
                PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
                storeQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
                storeQuery.maxCacheAge = 60 * 60 * 24; //clears cache every 24 hours
				storeQuery.limit = 20; //TODO: paginate
                [storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
				[storeQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];

                [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedStores, NSError *error){
                    //for (PFObject *store in fetchedStores){
                    for (int i = 0 ; i <[fetchedStores count]; i++) {
                        PFObject *store = fetchedStores[i];
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
                             

                         }//end if stores is not in list
                        
                        
                    }//end for all fetched loop
                    
                    [searchTable reloadData];
                }]; //end get stores
            }]; //end get user location
        }
	 */
}

- (void)reload
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        userLocation = geoPoint;

        storeList = [[storeList sortedArrayUsingComparator:^(id obj1, id obj2) {
            
            PFGeoPoint *storeLocation1 = [PFGeoPoint geoPointWithLatitude:[[obj1 valueForKey:@"latitude"] doubleValue] longitude:[[obj1 valueForKey:@"longitude"] doubleValue]];
            double distanceToStore1 = [userLocation distanceInMilesTo:storeLocation1];
            
            PFGeoPoint *storeLocation2 = [PFGeoPoint geoPointWithLatitude:[[obj2 valueForKey:@"latitude"] doubleValue] longitude:[[obj2 valueForKey:@"longitude"] doubleValue]];
            double distanceToStore2 = [userLocation distanceInMilesTo:storeLocation2];
            
            if (distanceToStore1 > distanceToStore2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (distanceToStore1 < distanceToStore2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
            
        }] mutableCopy];
        
        [searchTable reloadData];

    }];
    
}


//set up UI configuration
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:globalToolbar];
        
    storeList = [[NSMutableArray alloc] init];
    
    searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStylePlain];
    [searchTable setDataSource:self];
    [searchTable setDelegate:self];
    [[self view] addSubview:searchTable];
    
    if (_downloadFromNetwork) {
        [self setup];
    }
    else {
        [self reload];
    }


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadedPics:)
                                                 name:@"FinishedLoadingPic"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:@"addedOrRemovedStore"
                                               object:nil];

    //[self reload];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FinishedLoadingPic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addedOrRemovedStore" object:nil];
     */
}


-(void)receiveLoadedPics:(NSNotification *) notification
{
    [searchTable reloadData];
}

- (void)dismissPresentedViewController
{
    //[[self modalDelegate] didDismissPresentedViewController];
}

- (void)didDismissPresentedViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];;
}

 #pragma mark - Table view data source
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
     return 1;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
     return [storeList count];
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
	 /*
     static NSString *CellIdentifier = @"StoreCell";
      StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         //cell = [[StoreCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
         cell = [[[NSBundle mainBundle]loadNibNamed:@"StoreCell" owner:self options:nil]objectAtIndex:0];

     }
     
     [[cell punchesPic] setHidden:TRUE];
     [[cell numberOfPunches] setHidden:TRUE];
     
     Store *currentCellStore = [storeList objectAtIndex:indexPath.row];
     
      PFGeoPoint *storeLocation = [PFGeoPoint geoPointWithLatitude:currentCellStore.latitude longitude:currentCellStore.longitude];
     [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
         userLocation = geoPoint;

      double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
         cell.distance.text = [NSString stringWithFormat:@"%.2f mi", distanceToStore];

         
     }];

     
     NSString *neighborhood = [currentCellStore valueForKey:@"neighborhood"];
     NSString *state = [currentCellStore valueForKey:@"state"];
     NSString *addressString = [currentCellStore valueForKey:@"street"];
     
     if ([neighborhood length]>0){
         addressString = [addressString stringByAppendingFormat:@", %@", neighborhood];
     }
     else{
         addressString = [addressString stringByAppendingFormat:@", %@", state];
     }
     
     NSArray *categories = [[currentCellStore mutableSetValueForKey:@"categories"] allObjects];
     NSString *categoryString = @"";
     for (int i = 0; i <[categories count]; i++){
         categoryString = [categoryString stringByAppendingString:[categories[i] valueForKey:@"name"]];
         if (i!= [categories count]-1){
             categoryString = [categoryString stringByAppendingFormat:@", "];
         }
     }
     
     if ([localUser alreadyHasStoreSaved:[currentCellStore objectId]]){
         PatronStore *patronStore = [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, [currentCellStore objectId]]];
         int punches = [[patronStore punch_count] intValue];
         [[cell punchesPic] setHidden:FALSE];
         [[cell numberOfPunches] setHidden:FALSE];
         [[cell numberOfPunches] setText:[NSString stringWithFormat:@"%d %@", punches, (punches==1)?@"punch":@"punches"]];
     }
     
     cell.storeAddressLabel.text = addressString;
	 cell.storeCategoriesLabel.text = categoryString;
     cell.storeNameLabel.text = [currentCellStore valueForKey:@"store_name"];
     cell.storeImageLabel.image = [UIImage imageWithData:[currentCellStore valueForKey:@"store_avatar"]];
     
     return cell;
	  */
 }

#pragma mark - Table View delegate methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	PlacesDetailViewController *placesDetailVC = [[PlacesDetailViewController alloc]init];
	[self presentViewController:placesDetailVC animated:YES completion:NULL];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

@end
