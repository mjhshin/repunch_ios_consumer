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

#import "MGScrollView.h"
#import "MGLineStyled.h"
#import "MGTableBoxStyled.h"

@implementation PlacesSearchViewController{
    __block NSMutableArray *storeList;
    MGScrollView *scroller;
    MGTableBoxStyled *storesSection;
    UIToolbar *globalToolbar;
    PFGeoPoint *userLocation;
}

//set up data model
- (void)setup {
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
                    
                    //add table cell for each store
                    
                    //converting Parse PFFile to UIImage
                    PFFile *picFile = [store objectForKey:@"store_avatar"];
                    [picFile getDataInBackgroundWithBlock:^(NSData *picData, NSError *error){
                     
                         BOOL storeIsInList = FALSE;
                         for (NSString *storeId in storeList){
                             if ([storeId isEqualToString:[store objectId]]){
                                 storeIsInList = TRUE;
                                 break;
                             }
                         }
                        
                        //store list of stores
                         if(!storeIsInList){
                             [storeList addObject:[store objectId]];
                             
                             //cell view
                             UIView *storeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
                             
                             //cell view: image view
                             UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 65, 65)];
                             imageView.image = [UIImage imageWithData:picData];
                             [storeView addSubview:imageView];
                             
                             //cell view: store name view
                             UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, 200, 30)];
                             [nameLabel setText:[store objectForKey:@"store_name"]];
                             [nameLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:14]];
                             [nameLabel setNumberOfLines:2];
                             [nameLabel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
                             [storeView addSubview:nameLabel];
                             
                             //this might be useful later
                             /*
                             PFGeoPoint *storeLocation = [store objectForKey:@"coordinates"];
                             double distanceToStore = [userLocation distanceInMilesTo:storeLocation];
                             NSLog(@"distance is %g", distanceToStore);
                              */
                             
                             //cell view: store info info
                             NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", [store objectForKey:@"street"], [store objectForKey:@"city"], [store objectForKey:@"state"], [store objectForKey:@"zip"]];
                             UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 35, 200, 40)];
                             [addressLabel setTextAlignment:NSTextAlignmentLeft];
                             [addressLabel setText:addressString];
                             [addressLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
                             [addressLabel setNumberOfLines:4];
                             [addressLabel setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
                             [addressLabel setTextColor:[UIColor blackColor]];
                             [storeView addSubview:addressLabel];
                             
                             MGLineStyled *row = [MGLineStyled lineWithLeft:storeView right:nil size:(CGSize){300, 100}];
                             
                             //add gesture recognizer such that on tap, opens up detail view
                             row.onTap = ^{
                                 PlacesDetailViewController *placeDetailVC = [[PlacesDetailViewController alloc]init];
                                 placeDetailVC.modalDelegate = self;
                                 placeDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                 
                                 placeDetailVC.storeObject = store;
                                 placeDetailVC.storePic = picData;
                                 
                                 [self presentViewController:placeDetailVC animated:YES completion:NULL];
                                 
                             };
                             
                             //add to table view
                             [storesSection.topLines addObject:row];
                             [storesSection layout];
                            
                         }//end if stores is not in list
                        
                        
                    }]; //end get picture data
                    
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
    
    //add scroll view for table cells
    scroller = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:scroller];
    [scroller setDelegate:self];
    [[self view] sendSubviewToBack:scroller];
    
    //Table layout for store lists
    storesSection = MGTableBoxStyled.box;
    [storesSection setTopMargin:57];
    [scroller.boxes addObject:storesSection];
    
    [scroller layoutWithSpeed:0.3 completion:nil];
    [scroller scrollToView:storesSection withMargin:10];
    
    storeList = [[NSMutableArray alloc] init];

}

- (void)dismissPresentedViewController{
    [[self modalDelegate] didDismissPresentedViewController];
}

- (void)didDismissPresentedViewController{
    [self dismissPresentedViewController];
}

@end
