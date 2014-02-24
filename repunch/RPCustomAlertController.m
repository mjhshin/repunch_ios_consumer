//
//  RPVRewardAlertViewController.m
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPCustomAlertController.h"
//#import "RPRedeem+RedeemAddOn.h"
//#import "RPVCSceneManager.h"
//#import "Macros.h"
//#import "Utilities.h"

@interface RPCustomAlertController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;


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
    return alert;}



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

    alert.view.frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
                                                                  withDynamicLabels:@[alert.label1]
                                                            andInitialHights:@[@(CGRectGetHeight(alert.label1.frame))]];
    alert.initialFrame = alert.view.frame;


    [alert showAlert];
}


+(void)alertForRedeemWithTitle:(NSString *)title punches:(NSString *)punch dectiption:(NSString *)desc andBlock:(RPCustomAlertActionButtonBlock)block
{

    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"RedeemAlert"];
    alert.titleLabel.text = title ;
    alert.label1.text = punch;
    alert.label2.text = desc;

    alert.view.frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
                                                           withDynamicLabels:@[alert.label1]
                                                            andInitialHights:@[@(CGRectGetHeight(alert.label1.frame))]];
    alert.initialFrame = alert.view.frame;

    alert.alertBlock = block;
    [alert showAlert];
}

- (IBAction)close:(UIButton*)sender
{

    RPCustomAlertActionButton button = NoneButton;
    if (sender == self.redeemButton) {
        button = RedeemButton;
    }
    else if (self.giftButton == sender){
        button = GiftButton;
    }

    if (self.alertBlock) {
        self.alertBlock(button);
    }


    [self hideAlert];
}

+ (CGRect)frameForViewWithInitialFrame:(CGRect)viewInitialFrame withDynamicLabels:(NSArray*)labels andInitialHights:(NSArray*)initialHeights
{
    CGFloat totalDelta = 0;

    for (NSUInteger i = 0  ; i < labels.count; i++) {

        UILabel *label = labels[i];
        CGFloat initialHeight = [initialHeights[i] floatValue];

        CGSize max = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);

        CGFloat expectedHeight = [label.text sizeWithFont:label.font
                                        constrainedToSize:max
                                            lineBreakMode:label.lineBreakMode].height;

        CGFloat delta = expectedHeight - initialHeight;

        if (delta < 1) {
            delta = 0;
        }

        if (label.text.length < 1) {
            delta -= label.font.pointSize * 1.4f;
        }

        totalDelta += delta;
    }

    viewInitialFrame.size.height +=  totalDelta;
    
    return viewInitialFrame;
}




@end