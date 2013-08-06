//
//  PlacesSearchViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "SearchTableViewCell.h"
#import "GradientBackground.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "DataManager.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *toolbar;

@property (nonatomic, strong) DataManager* sharedData;
@property (nonatomic, strong) PFObject* patron;
@property (nonatomic, strong) NSMutableArray *storeIdArray;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)closeView:(id)sender;

@end
