//
//  AttachmentTableViewCell.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/19/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPButton.h"

@interface AttachmentTableViewCell : UITableViewCell

+ (AttachmentTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

- (void)setOfferBorder;
- (void)setGiftBorder;

@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *rewardTitle;
@property (weak, nonatomic) IBOutlet UILabel *rewardDescription;
@property (weak, nonatomic) IBOutlet RPButton *redeemButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleVerticalPaddingConstraint;

@end
