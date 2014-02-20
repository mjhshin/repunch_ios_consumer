//
//  MessageTableViewCell.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/19/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "RepunchUtils.h"

@interface MessageTableViewCell ()

@property (assign, nonatomic) CGFloat initialSenderNameHeight;
@property (assign, nonatomic) CGFloat initialSubjectHeight;
@property (assign, nonatomic) CGFloat initialSendTimeHeight;
@property (assign, nonatomic) CGFloat initialBodyHeight;

@property (assign, nonatomic) CGRect initialFrame;

@end

@implementation MessageTableViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (MessageTableViewCell *)cell
{
	return [[[NSBundle mainBundle] loadNibNamed:[self reuseIdentifier]
										  owner:self
										options:nil] objectAtIndex:0];
}


-(void)awakeFromNib
{
    self.initialFrame = self.frame;
    self.initialSendTimeHeight   = CGRectGetHeight(self.sendTime.frame);
    self.initialSubjectHeight    = CGRectGetHeight(self.subject.frame);
    self.initialSenderNameHeight = CGRectGetHeight(self.senderName.frame);
    self.initialBodyHeight       = CGRectGetHeight(self.body.frame);


}

-(CGFloat)height
{
   return  [RepunchUtils frameForViewWithInitialFrame:self.initialFrame
                                          withDynamicLabels:@[self.subject, self.senderName, self.sendTime, self.body]
                                           andInitialHights:@[@(self.initialSenderNameHeight),
                                                              @(self.initialSenderNameHeight),
                                                              @(self.initialSendTimeHeight),
                                                              @(self.initialBodyHeight)]].size.height;
}


@end
