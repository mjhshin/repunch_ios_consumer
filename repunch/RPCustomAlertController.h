//
//  RPVRewardAlertViewController.h
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPAlertController.h"

@class RPCustomAlertController;

typedef NS_ENUM(NSUInteger, RPCustomAlertActionButton) {
    NoneButton, RedeemButton, GiftButton, DeleteButton, SendButton, ConfirmButton, DenyButton
};

typedef void(^RPCustomAlertActionButtonBlock)(RPCustomAlertController *alert, RPCustomAlertActionButton buttonType, id anObject);


@interface RPCustomAlertController : RPAlertController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


+ (void)showDefaultAlertWithTitle:(NSString*)title andMessage:(NSString*)message;

+ (void)showPunchCodeAlertWithCode:(NSString*)punchCode;

+ (void)showNetworkErrorAlert;


+ (void)showDecisionAlertWithTitle:(NSString*)title
                                andMessage:(NSString*)message
                                  andBlock:(RPCustomAlertActionButtonBlock)block;


+ (void)showRedeemAlertWithTitle:(NSString*)title
                                 punches:(NSInteger)punches
                                andBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)showDeleteMessageAlertWithBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)showDeleteMyPlaceAlertWithBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)showCreateMessageAlertWithRecepient:(NSString*)recepient
                                           andBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)showCreateGiftMessageAlertWithRecepient:(NSString*)recepient
                                            rewardTitle:(NSString*)rewardTitle
                                               andBlock:(RPCustomAlertActionButtonBlock)block;

@end
