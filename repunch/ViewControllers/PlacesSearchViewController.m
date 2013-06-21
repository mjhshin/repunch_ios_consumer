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
#import <Parse/Parse.h>

@implementation PlacesSearchViewController{
    __block NSMutableArray *storeList;
    UIToolbar *globalToolbar;
    PFGeoPoint *userLocation;
    UITableView *searchTable;

}

//set up data model
- (void)setup {
    if ([CLLocationManager locationServicesEnabled]) {
        //get user location
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
            userLocation = geoPoint;
            
            //only get ten closest stores
            PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
            //[storeQuery clearCachedResult];
            storeQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
            storeQuery.maxCacheAge = 60 * 60 * 24; //clears cache every 24 hours
            [storeQuery whereKey:@"coordinates" nearGeoPoint:userLocation];
            storeQuery.limit = 10;

            [storeQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedStores, NSError *error){
                for (PFObject *store in fetchedStores){
                    
                    //add table cell for each store
                     
                     BOOL storeIsInList = FALSE;
                    for (id localStore in storeList){
                        if ([[localStore objectId] isEqualToString:[store objectId]]){
                            storeIsInList = TRUE;
                            break;
                        }
                    }
                    
                    //store list of stores
                     if(!storeIsInList){
                         [storeList addObject:store];
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
     static NSString *CellIdentifier = @"Cell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
     }
     
     //converting Parse PFFile to UIImage
     PFFile *picFile = [[storeList objectAtIndex:indexPath.row] objectForKey:@"store_avatar"];
     [picFile getDataInBackgroundWithBlock:^(NSData *picData, NSError *error){
         
         //cell view: image view
         UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, 20, 65, 65)];
         imageView.image = [UIImage imageWithData:picData];
         [cell addSubview:imageView];
         

         [searchTable reloadData];
         
     }];
     
     //this might be useful later
     /*
      PFGeoPoint *storeLocation = [store objectForKey:@"coordinates"];
      double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
      NSLog(@"distance is %g", distanceToStore);
      */
     
     NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", [[storeList objectAtIndex:indexPath.row] objectForKey:@"street"], [[storeList objectAtIndex:indexPath.row] objectForKey:@"city"], [[storeList objectAtIndex:indexPath.row] objectForKey:@"state"], [[storeList objectAtIndex:indexPath.row] objectForKey:@"zip"]];
     
     [[cell textLabel] setText:[[storeList objectAtIndex:indexPath.row] objectForKey:@"store_name"]];
     [[cell textLabel] setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:14]];
     [[cell detailTextLabel] setText:addressString];
     [[cell detailTextLabel] setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:13]];
     [[cell detailTextLabel] setNumberOfLines:4];
     
     return cell;

 }


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
