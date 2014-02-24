//
//  RPVRewardAlertViewController.h
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPAlertController.h"
@class RPReward;
@class RPRedeem;

typedef NS_ENUM(NSUInteger, RPCustomAlertActionButton)
{
    RejectButton, ValidateButton, Save
};

typedef void(^RPCustomAlertActionButtonBlock)(RPCustomAlertActionButton buttonType);

@interface RPCustomAlertController : RPAlertController

+ (void)alertViewForRedeemHistory:(RPRedeem*)redeem;
+ (void)alertViewForRedeemPending:(RPRedeem*)redeem withRejectValidateBlock:(RPCustomAlertActionButtonBlock)block;
+ (void)alertForReward:(RPReward*)reward;
+ (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (void)alertForSaveWithTitle:(NSString*)title andMessage:(NSString*)message withBlock:(RPCustomAlertActionButtonBlock)block;

+ (void)alertForNetworkError;

@end
