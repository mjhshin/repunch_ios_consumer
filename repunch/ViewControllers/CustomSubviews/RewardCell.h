//
//  RewardCell.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rewardName;
@property (weak, nonatomic) IBOutlet UILabel *rewardDescription;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPunches;
@property (weak, nonatomic) IBOutlet UIImageView *padlockPic;

@end
