//
//  StoreCell.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/24/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *storeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *storeAddressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *storeImageLabel;

@end
