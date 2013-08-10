//
//  SearchViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

@class SearchViewController;

@protocol  SearchViewControllerDelegate <NSObject>
- (void)updateTableViewFromSearch:(SearchViewController *)controller forStoreId:(NSString *)storeId andAddRemove:(BOOL)isAddRemove;
@end

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "SearchTableViewCell.h"
#import "GradientBackground.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "DataManager.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, StoreViewControllerDelegate>

@property (nonatomic, weak) id <SearchViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIView *toolbar;

@property (nonatomic, strong) DataManager* sharedData;
@property (nonatomic, strong) PFObject* patron;
@property (nonatomic, strong) NSMutableArray *storeIdArray;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)closeView:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
