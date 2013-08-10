//
//  MyPlacesViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreViewController.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "MyPlacesTableViewCell.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "DataManager.h"
#import "SIAlertView.h"
#import <Parse/Parse.h>

@interface MyPlacesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, StoreViewControllerDelegate, SearchViewControllerDelegate>

- (IBAction)openSettings:(id)sender;
- (IBAction)showPunchCode:(id)sender;
- (IBAction)openSearch:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) DataManager *sharedData;
@property (nonatomic, strong) PFObject *patron;
@property (nonatomic, strong) NSMutableArray *storeIdArray;
@property (nonatomic, strong) UITableView *myPlacesTableView;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end
