//
//  InboxTableViewCell.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPMessage.h"

@interface InboxTableViewCell : UITableViewCell

+ (InboxTableViewCell *)cell;
+ (NSString *)reuseIdentifier;

- (void)setMessageRead;
- (void)setMessageUnread;
- (void)setMessageTypeIcon:(RPMessageType)messageType forReadMessage:(BOOL)isRead;

+ (CGFloat)height;

@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *messagePreview;
@property (weak, nonatomic) IBOutlet UILabel *dateSent;
@property (weak, nonatomic) IBOutlet UIImageView *offerPic;

@end
