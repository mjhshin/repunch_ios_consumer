//
//  StoreCell.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/24/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeCategoriesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *storeImageLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPunches;
@property (weak, nonatomic) IBOutlet UIImageView *punchesPic;
@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
