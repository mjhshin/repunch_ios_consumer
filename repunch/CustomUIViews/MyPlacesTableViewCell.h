//
//  MyPlacesTableViewCell.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPImageView.h"

@interface MyPlacesTableViewCell : UITableViewCell

+ (MyPlacesTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet RPImageView *storeImage;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *numPunches;
@property (weak, nonatomic) IBOutlet UIImageView *rewardIcon;
@property (weak, nonatomic) IBOutlet UILabel *rewardLabel;

@end
