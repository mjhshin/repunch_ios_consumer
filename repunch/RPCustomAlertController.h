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
    NoneButton, RedeemButton, GiftButton
};

typedef void(^RPCustomAlertActionButtonBlock)(RPCustomAlertActionButton buttonType);


@interface RPCustomAlertController : RPAlertController

+ (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message;

+ (void)alertForNetworkError;

+ (void)alertForRedeemWithTitle:(NSString*)title punches:(NSString*)punch dectiption:(NSString*)desc andBlock:(RPCustomAlertActionButtonBlock)block ;

@end
