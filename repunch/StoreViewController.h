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
#import "GradientBackground.h"
#import "DataManager.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface StoreViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSMutableArray *rewardArray;
@property (nonatomic, strong) UITableView *rewardTableView;

@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIImageView *storePic;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storeHours;
@property (weak, nonatomic) IBOutlet UILabel *storeOpen;
@property (weak, nonatomic) IBOutlet UILabel *numPunches;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;
@property (weak, nonatomic) IBOutlet UIButton *addPlaceBtn;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLbl;
@property (weak, nonatomic) IBOutlet UIView *callView;
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)callButton:(id)sender;
- (IBAction)mapButton:(id)sender;
- (IBAction)feedbackButton:(id)sender;
- (IBAction)addStore:(id)sender;
- (IBAction)deleteStore:(id)sender;
- (IBAction)closeView:(id)sender;

@end
