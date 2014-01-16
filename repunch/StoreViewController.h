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
//@property (nonatomic, strong) UITableView *rewardTableView;
//@property (nonatomic, strong) UITableViewController *tableViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeImageViewHeightConstraint;

// store header
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *storeNameBackground;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIImageView *storeImage;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storeHoursToday;
@property (weak, nonatomic) IBOutlet UILabel *storeHoursOpen;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

- (IBAction)callButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)feedbackButtonAction:(id)sender;

// tableview section header
@property (strong, nonatomic) IBOutlet UIView *sectionHeaderView;

@property (weak, nonatomic) IBOutlet UILabel *punchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *punchStaticLabel;

@end
