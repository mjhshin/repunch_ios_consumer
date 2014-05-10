//
//  RedeemViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 5/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"
#import "RPRadarView.h"

@interface RedeemViewController : UIViewController

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSString *storeId;
@property (strong, nonatomic) NSString *patronStoreId;
@property (assign, nonatomic) int rewardId;
@property (strong, nonatomic) NSString *messageStatusId;

@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet RPRadarView *radarView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIView *punchCountView;
@property (weak, nonatomic) IBOutlet UICountingLabel *punchCountLabel;

- (IBAction)exitButtonAction:(id)sender;

@end
