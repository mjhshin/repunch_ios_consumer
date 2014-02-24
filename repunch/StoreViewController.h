//
//  StoreViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SIAlertView.h"
#import "StoreTableViewCell.h"
#import "AppDelegate.h"
#import "ComposeMessageViewController.h"
#import "FacebookFriendsViewController.h"
#import "DataManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookPost.h"
#import "RPConstants.h"
#import "RPImageView.h"
#import "RPTableView.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
													UIGestureRecognizerDelegate, FacebookFriendsDelegate,
													UIScrollViewDelegate>

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSString *storeLocationId;

@property (weak, nonatomic) IBOutlet RPTableView *tableView;

// store header
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *storeNameBackground;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet RPImageView *storeImage;
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
@property (weak, nonatomic) IBOutlet UIButton *chainFeedbackButton;

- (IBAction)callButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)feedbackButtonAction:(id)sender;
- (IBAction)storeInfoGestureAction:(UITapGestureRecognizer *)sender;

// tableview section header
@property (strong, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *punchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *punchStaticLabel;
@property (strong, nonatomic) IBOutlet UIView *sectionHeaderViewAdd;

@property (weak, nonatomic) IBOutlet UIButton *saveStoreButton;
- (IBAction)saveStoreButtonAction:(id)sender;

@end
