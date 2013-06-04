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
    SettingsNavigationController *snc;
    PlaceDetailViewController *pdvc;
    PlacesViewController *searchvc;
    UIViewController *delegate;
    BOOL isSearch;
    PFGeoPoint *location;
    NSArray *my_related_places;
}

@property (nonatomic, retain) NSMutableArray *placesData;
@property (nonatomic, retain) UITableView *placesTableView;
@property (nonatomic, retain) SettingsNavigationController *snc;
@property (nonatomic, retain) PlaceDetailViewController *pdvc;
@property (nonatomic, retain) PlacesViewController *searchvc;
@property (nonatomic, retain) UIViewController *delegate;
@property (nonatomic, readwrite) BOOL isSearch;
@property (nonatomic, retain) PFGeoPoint *location;
@property (nonatomic, retain) NSArray *my_related_places;

- (void)closePlaceDetail;
- (void)closeSettings;
- (void)sortPlaces;
- (void)loadPlaces;

@end
