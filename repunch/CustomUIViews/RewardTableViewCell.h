//
//  RewardTableViewCell.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardTableViewCell : UITableViewCell

+ (RewardTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *rewardTitle;
@property (weak, nonatomic) IBOutlet UILabel *rewardDescription;
@property (weak, nonatomic) IBOutlet UILabel *rewardPunches;
@property (weak, nonatomic) IBOutlet UILabel *rewardPunchesStatic;
@property (weak, nonatomic) IBOutlet UIImageView *rewardStatusIcon;
@property (weak, nonatomic) IBOutlet UIView *whiteContentView;
@property (weak, nonatomic) IBOutlet UIView *dividerView;

@end
