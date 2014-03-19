//
//  SearchTableViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTableViewCell.h"
#import <Parse/Parse.h>
#import "RPTableView.h"
#import "RepunchUtils.h"
#import "DataManager.h"
#import "RPConstants.h"
#import "RPStoreLocation.h"

@class SearchTableViewController;

@protocol SearchTableVCDelegate <NSObject>
- (void)refreshData:(SearchTableViewController *)controller forPaginate:(BOOL)paginate;
@end

@interface SearchTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SearchTableVCDelegate> delegate;

@property (weak, nonatomic) IBOutlet RPTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyResultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationServicesLabel;

@property (strong, nonatomic) NSArray *storeLocationIdArray;
@property (strong, nonatomic) PFGeoPoint *userLocation;
@property (assign, nonatomic) BOOL loadInProgress;
@property (assign, nonatomic) BOOL paginateReachEnd;

- (void)refreshTableView;
- (void)showRefreshViews:(BOOL)paginate;
- (void)hideRefreshViews:(BOOL)paginate;

@end
