//
//  SearchViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "SearchTableViewCell.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "DataManager.h"
#import "RPConstants.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) DataManager* sharedData;
@property (nonatomic, strong) PFObject* patron;
@property (nonatomic, strong) NSMutableArray *storeIdArray;
@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyResultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationServicesLabel;

@end
