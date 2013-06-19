//
//  PlaceDetailViewController.h
//  repunch
//
//  Created by CambioLabs on 3/25/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Store.h"
#import "Reward.h"
#import "Hour.h"

#import "ModalDelegate.h"

@interface PlaceDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *placeRewardData;
    UIViewController *delegate;
    Store *place;
    UIButton *placeAddButton;
    UIView *placeAddOrRemove;
    UIView *placeBottomContainer;
    BOOL isSearch;
    PlaceDetailMapViewController *placesDetailMapVC;
    UILabel *placePunchesLabel;
}

@property (nonatomic, retain) NSMutableArray *placeRewardData;
@property (nonatomic, retain) UIViewController *delegate;
@property (nonatomic, retain) Store *place;
@property (nonatomic, retain) UIButton *placeAddButton;
@property (nonatomic, retain) UIView *placeAddOrRemove;
@property (nonatomic, retain) UIView *placeBottomContainer;
@property (nonatomic, readwrite) BOOL isSearch;
@property (nonatomic, retain) PlaceDetailMapViewController *placesDetailMapVC;
@property (nonatomic, retain) UILabel *placePunchesLabel;

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;


- (void)closePlaceMap;

@end
