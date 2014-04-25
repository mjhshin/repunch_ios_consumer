//
//  PunchViewController.h
//  BLE Central
//
//  Created by Michael Shin on 4/8/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"
#import "RPRadarView.h"

@interface PunchViewController : UIViewController

@property (weak, nonatomic) IBOutlet RPRadarView *radarView;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeNameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UIButton *wrongStoreButton;

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *punchReceivedLabel;
@property (weak, nonatomic) IBOutlet UIView *punchCountView;
@property (weak, nonatomic) IBOutlet UICountingLabel *punchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *unlockedRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreRewardsLabel;

@property (strong, nonatomic) UIImageView *backgroundImageView;

- (IBAction)wrongStoreButtonAction:(id)sender;
- (IBAction)exitButtonAction:(id)sender;

@end
