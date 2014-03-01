//
//  RPVRewardAlertViewController.h
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPAlertController.h"

typedef NS_ENUM(NSUInteger, RPCustomAlertActionButton) {
    NoneButton, RedeemButton, GiftButton, DeleteButton, SendButton, ConfirmButton
};

typedef void(^RPCustomAlertActionButtonBlock)(RPCustomAlertActionButton buttonType, id anObject);


@interface RPCustomAlertController : RPAlertController

+ (void)showDefaultAlertWithTitle:(NSString*)title andMessage:(NSString*)message;

+ (void)showDecisionAlertWithTitle:(NSString*)title
						andMessage:(NSString*)message
						  andBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)showNetworkErrorAlert;

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
