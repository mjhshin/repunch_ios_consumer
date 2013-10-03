//
//  StoreViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

@class StoreViewController;

@protocol StoreViewControllerDelegate <NSObject>
- (void)updateTableViewFromStore:(StoreViewController *)controller forStoreId:(NSString *)storeId andAddRemove:(BOOL)isAddRemove;
@end

#import "StoreMapViewController.h"
#import "SIAlertView.h"
#import "RewardTableViewCell.h"
#import "AppDelegate.h"
#import "ComposeMessageViewController.h"
#import "FacebookFriendsViewController.h"
#import "GradientBackground.h"
#import "DataManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookPost.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FacebookFriendsDelegate>

@property (nonatomic, weak) id <StoreViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSMutableArray *rewardArray;
@property (nonatomic, strong) UITableView *rewardTableView;
@property (nonatomic, strong) UITableViewController *tableViewController;

@property (strong, nonatomic) IBOutlet UIView *headerView;

// store header
@property (weak, nonatomic) IBOutlet UIImageView *storeImage;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storeHoursToday;
@property (weak, nonatomic) IBOutlet UILabel *storeHoursOpen;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;
@property (weak, nonatomic) IBOutlet UIButton *addToMyPlacesButton;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

- (IBAction)callButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)feedbackButtonAction:(id)sender;

@end
