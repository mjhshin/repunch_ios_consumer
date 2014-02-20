//
//  MessageTableViewCell.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/19/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell

+ (MessageTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *sendTime;
@property (weak, nonatomic) IBOutlet UILabel *body;

-(CGFloat)height;

@end
