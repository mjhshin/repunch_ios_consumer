//
//  PunchResultViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 4/14/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"

@interface PunchResultViewController : UIViewController

@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) NSString *storeId;
@property (assign, nonatomic) NSUInteger punchesReceived;

@property (weak, nonatomic) IBOutlet UILabel *punchReceivedLabel;
@property (weak, nonatomic) IBOutlet UIView *punchCountView;
@property (weak, nonatomic) IBOutlet UICountingLabel *punchCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *unlockedRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *rewardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreRewardsLabel;

@end
