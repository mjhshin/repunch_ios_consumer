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
#include "RPStoreLocation.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet RPTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyResultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationServicesLabel;

@end
