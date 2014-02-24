//
//  RPVRewardAlertViewController.m
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPCustomAlertController.h"
#import "RPReward+RewardAddOn.h"
#import "RPRedeem+RedeemAddOn.h"
#import "RPVCSceneManager.h"
#import "Macros.h"
#import "Utilities.h"

@interface RPCustomAlertController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;



@property (strong, nonatomic) RPCustomAlertActionButtonBlock alertBlock;

@end

@implementation RPCustomAlertController


+ (instancetype)alertFromStoryboard:(NSString*)string
{
    static UIStoryboard *storyboard = nil;
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Alerts" bundle:nil];
    }

    RPCustomAlertController *alert = [storyboard instantiateViewControllerWithIdentifier:string];
    UIView *view = alert.view;
    view = nil; // preload
    return alert;
}

+ (void)alertViewForRedeemHistory:(RPRedeem *)redeem
{
    RPCustomAlertController *alert = [RPCustomAlertController alertFromStoryboard:@"HistoryRedeemAlert"];
    [alert configureForRedeem:redeem];
    [alert showAlert];

}

+ (void)alertViewForRedeemPending:(RPRedeem *)redeem withRejectValidateBlock:(RPCustomAlertActionButtonBlock)block
{
     RPCustomAlertController *alert = [RPCustomAlertController alertFromStoryboard:@"PendingRedeemAlert"];
    [alert configureForRedeem:redeem];
    alert.alertBlock = block;
    [alert showAlert];

}

+ (void)alertForReward:(RPReward *)reward
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"RewardAlert"];

    alert.titleLabel.text = reward.name;
    alert.label3.text = reward.rewardDescription;
    alert.label1.text = [reward.punches stringValue];

    alert.view.frame = [Utilities frameForViewWithInitialFrame:alert.view.frame
                                                                   withDynamicLabels:@[alert.label3]
                                                             andInitialHights:@[@(CGRectGetHeight(alert.label3.frame))]];
    alert.initialFrame = alert.view.frame;

    [alert showAlert];
}


+ (void)alertForNetworkError
{

    static RPCustomAlertController * alert =  nil;
    if (!alert) {
        alert = [RPCustomAlertController alertFromStoryboard:@"NetworkAlert"];
    }
    
    [alert showAlert];
}

+ (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"MessageAlert"];
    alert.titleLabel.text = NSLocalizedString(title, nil) ;
    alert.label1.text = NSLocalizedString(message, nil);

    alert.view.frame = [Utilities frameForViewWithInitialFrame:alert.view.frame
                                                                  withDynamicLabels:@[alert.label1]
                                                            andInitialHights:@[@(CGRectGetHeight(alert.label1.frame))]];
    alert.initialFrame = alert.view.frame;


    [alert showAlert];
}

+ (void)alertForSaveWithTitle:(NSString*)title andMessage:(NSString*)message withBlock:(RPCustomAlertActionButtonBlock)block
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"MessageSaveAlert"];
    alert.titleLabel.text = NSLocalizedString(title, nil) ;
    alert.label1.text = NSLocalizedString(message, nil);

    alert.view.frame = [Utilities frameForViewWithInitialFrame:alert.view.frame
                                                                  withDynamicLabels:@[alert.label1]
                                                            andInitialHights:@[@(CGRectGetHeight(alert.label1.frame))]];
    alert.initialFrame = alert.view.frame;

    alert.alertBlock = block;
    [alert showAlert];
}


-(void)dealloc
{
    NSLog(@"Controller Dealloc");
}

- (void)configureForRedeem:(RPRedeem*)redeem{


    NSString *punchesString = nil;
    if ([redeem.punches integerValue] == 0) {
        punchesString = @"Gift/Offert";
    }
    else {
        NSString *pluralString	= [redeem.punches integerValue] > 1 ? @"Punches" : @"Punch";
        punchesString = [NSString stringWithFormat:@"%@ %@", redeem.punches, pluralString];
    }
    
    static NSDateFormatter * formatter = nil;

    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a"];
    }

    self.titleLabel.text = redeem.title;
    self.label1.text = punchesString;
    self.label2.text = [formatter stringFromDate:redeem.updatedAt];
    self.label3.text = redeem.customerName;
    if ([redeem.punches integerValue] > 0) {
        // TODO: set offer/gift
    }
}


- (IBAction)close:(UIButton*)sender
{
    if (sender == self.rejectButton) {
        BLOCK_SAFE_RUN(self.alertBlock, RejectButton);
    }
    else if (self.validateButton == sender){
        BLOCK_SAFE_RUN(self.alertBlock, ValidateButton);
    }
    else if (self.saveButton == sender){
        BLOCK_SAFE_RUN(self.alertBlock, Save);
    }

    [self hideAlert];
}


@end
