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
#import "RepunchUtils.h"

@interface RPCustomAlertController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


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

    CGRect frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
                                                                  withDynamicLabels:@[alert.label1]
                                                            andInitialHights:@[@(CGRectGetHeight(alert.label1.frame))]];


    if (!message) {
        //frame.size.height -= 20;
    }
    alert.view.frame = frame;


    [alert showAlert];
}


+ (void)alertForRedeemWithTitle:(NSString*)title punches:(NSInteger)punches andBlock:(RPCustomAlertActionButtonBlock)block ;
{

    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"RedeemAlert" ];
    alert.titleLabel.text = title ;

    alert.label2.text = [NSString stringWithFormat:@"%i %@", punches , punches == 1 ? @"Punch" : @"Punches"];

    //alert.label1.text = punch;
    //alert.label2.text = desc;


    //alert.view.frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
    //withDynamicLabels:@[alert.label1, alert.label2]
    //andInitialHights:@[@(CGRectGetHeight(alert.label1.frame)), @(CGRectGetHeight(alert.label2.frame))]];


    alert.alertBlock = block;
    [alert showAsAction];
}

+ (void)alertForDeletingMessageWithBlock:(RPCustomAlertActionButtonBlock)block
{

    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"DeleteMessageAlert" ];
    alert.alertBlock  = block;

    [alert showAsAction];
}


+(void)alertForDeletingPlacesWithBlock:(RPCustomAlertActionButtonBlock)block
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"DeleteStoreAlert" ];
    alert.alertBlock = block;
    [alert showAsAction];
}


+ (instancetype)actionForIdentifier:(NSString*)name;
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:name];
    alert.titleLabel.layer.cornerRadius = 5;
    alert.closeButton.layer.cornerRadius = 5;


    UIView *header = nil;

    for (UIView *view in alert.view.subviews) {
        if ([view.restorationIdentifier isEqualToString:@"HeaderLabel"]) {
            header = view;
            break;
        }
    }

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:header.bounds
                                                   byRoundingCorners: UIRectCornerTopLeft| UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(5.0, 15.0)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = header.bounds;
    maskLayer.path = maskPath.CGPath;
    header.layer.mask = maskLayer;



    UIButton *button = alert.deleteButton ? alert.deleteButton : alert.giftButton;
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                    byRoundingCorners: UIRectCornerBottomLeft| UIRectCornerBottomRight
                                                          cornerRadii:CGSizeMake(5.0, 15.0)];

    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = button.bounds;
    maskLayer2.path = maskPath2.CGPath;

    button.layer.mask = maskLayer2;

    return alert;

}



- (IBAction)close:(UIButton*)sender
{

    [self hideAlert];

    RPCustomAlertActionButton button = NoneButton;

    if (sender == self.redeemButton) {
        button = RedeemButton;
    }
    else if (self.giftButton == sender){
        button = GiftButton;
    }
    else if (self.deleteButton == sender ){
        button = DeleteButton;
    }

    if (self.alertBlock) {
        self.alertBlock(button);
    }

}

+ (CGRect)frameForViewWithInitialFrame:(CGRect)viewInitialFrame withDynamicLabels:(NSArray*)labels andInitialHights:(NSArray*)initialHeights
{
    CGFloat totalDelta = 0;

    for (NSUInteger i = 0  ; i < labels.count; i++) {

        UILabel *label = labels[i];
        CGFloat initialHeight = [initialHeights[i] floatValue];

        CGSize max = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);


        ///CGRect expectedRect =

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
