//
//  MyPlacesViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "PlacesDetailViewController.h"
#import "SettingsViewController.h"
#import "MyPlacesTableViewCell.h"
#import "GlobalToolbar.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "DataManager.h"
#import "SIAlertView.h"
#import <Parse/Parse.h>

@interface MyPlacesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (IBAction)openSettings:(id)sender;
- (IBAction)showPunchCode:(id)sender;
- (IBAction)openSearch:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *toolbar;

@property (nonatomic, strong) DataManager* sharedData;
@property (nonatomic, strong) PFObject* patron;
@property (nonatomic, strong) NSMutableArray* storeIdArray;
@property (nonatomic, strong) UITableView* myPlacesTableView;
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end
