//
//  PlacesViewController.h
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsNavigationController.h"
#import "PlaceDetailViewController.h"
#import "Retailer.h"
#import "Reward.h"
#import <Parse/Parse.h>

@interface PlacesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *placesData;
    UITableView *placesTableView;
    SettingsNavigationController *settingsNavVC;
    PlaceDetailViewController *placesDetailVC;
    PlacesViewController *searchVC;
    UIViewController *delegate;
    BOOL isSearch;
    PFGeoPoint *location;
    NSArray *myRelatedPlaces;
}

@property (nonatomic, retain) NSMutableArray *placesData;
@property (nonatomic, retain) UITableView *placesTableView;
@property (nonatomic, retain) SettingsNavigationController *settingsNavVC;
@property (nonatomic, retain) PlaceDetailViewController *placesDetailVC;
@property (nonatomic, retain) PlacesViewController *searchVC;
@property (nonatomic, retain) UIViewController *delegate;
@property (nonatomic, readwrite) BOOL isSearch;
@property (nonatomic, retain) PFGeoPoint *location;
@property (nonatomic, retain) NSArray *myRelatedPlaces;

- (void)closePlaceDetail;
- (void)closeSettings;
- (void)sortPlaces;
- (void)loadPlaces;

@end
