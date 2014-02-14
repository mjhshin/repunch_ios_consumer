//
//  StoreDetailTableViewCell.h
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsTableViewCell : UITableViewCell

+ (LocationsTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *locationTitle;
@property (weak, nonatomic) IBOutlet UILabel *locationSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *locationHours;
@property (weak, nonatomic) IBOutlet UILabel *locationDistance;

@end