//
//  StoreViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreMapViewController.h"
#import "SIAlertView.h"
#import "RewardTableViewCell.h"
#import "AppDelegate.h"
#import "ComposeMessageViewController.h"
#import "FacebookFriendsViewController.h"
#import "DataManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookPost.h"
#import "RPConstants.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
													UIGestureRecognizerDelegate, FacebookFriendsDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSString *storeLocationId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// store header
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *storeNameBackground;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIImageView *storeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *storeCategory;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storeHoursOpen;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;
@property (weak, nonatomic) IBOutlet UIView *storeInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeInfoViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

- (IBAction)callButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)feedbackButtonAction:(id)sender;
- (IBAction)storeInfoButtonAction:(id)sender;

// tableview section header
@property (strong, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UIView *sectionHeaderContentView;
@property (weak, nonatomic) IBOutlet UILabel *punchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *punchStaticLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *saveButtonSpinner;

- (IBAction)saveButtonAction:(id)sender;

@end
