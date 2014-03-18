//
//  MyPlacesViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "RPTableView.h"
#import "SettingsViewController.h"
#import "MyPlacesTableViewCell.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RPConstants.h"
#import "Reachability.h"

@interface MyPlacesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet RPTableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyMyPlacesLabel;

@end
