//
//  SavedStoreCell.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedStoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *storePic;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *numberPuches;
@property (weak, nonatomic) IBOutlet UIImageView *rewardPic;
@property (weak, nonatomic) IBOutlet UILabel *rewardLabel;

@end
