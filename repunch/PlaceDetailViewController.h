//
//  PlaceDetailViewController.h
//  repunch
//
//  Created by CambioLabs on 3/25/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceDetailMapViewController.h"
#import <Parse/Parse.h>
#import "Retailer.h"
#import "Reward.h"
#import "HoursObject.h"

@interface PlaceDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *placeRewardData;
    UIViewController *delegate;
    Retailer *place;
    UIButton *placeAddButton;
    UIView *placeAddOrRemove;
    UIView *placeBottomContainer;
    BOOL isSearch;
    PlaceDetailMapViewController *pdmvc;
    UILabel *placePunchesLabel;
}

@property (nonatomic, retain) NSMutableArray *placeRewardData;
@property (nonatomic, retain) UIViewController *delegate;
@property (nonatomic, retain) Retailer *place;
@property (nonatomic, retain) UIButton *placeAddButton;
@property (nonatomic, retain) UIView *placeAddOrRemove;
@property (nonatomic, retain) UIView *placeBottomContainer;
@property (nonatomic, readwrite) BOOL isSearch;
@property (nonatomic, retain) PlaceDetailMapViewController *pdmvc;
@property (nonatomic, retain) UILabel *placePunchesLabel;

- (void)closePlaceMap;

@end
