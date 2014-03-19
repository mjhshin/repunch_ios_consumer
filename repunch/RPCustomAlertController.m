//
//  RPVRewardAlertViewController.m
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPCustomAlertController.h"
#import "RepunchUtils.h"

#define MAX_BODY_LENGTH 255

@interface RPCustomAlertController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UILabel *postCharCount;

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

+ (void)showDefaultAlertWithTitle:(NSString*)title andMessage:(NSString*)message
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"MessageAlert"];
    alert.titleLabel.text = NSLocalizedString(title, nil);
    alert.label1.text = NSLocalizedString(message, nil);

    CGRect frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
													   withDynamicLabels:@[alert.titleLabel, alert.label1]
														andInitialHights:@[@(CGRectGetHeight(alert.titleLabel.frame)),
																		@(CGRectGetHeight(alert.label1.frame))]];
    alert.view.frame = frame;

    [alert showAlert];
}

+ (void)showPunchCodeAlertWithCode:(NSString*)punchCode
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"PunchCodeAlert"];
    alert.label1.text = punchCode;
	
    [alert showAlert];
}

+ (void)showNetworkErrorAlert
{
    static RPCustomAlertController * alert =  nil;
    if (!alert) {
        alert = [RPCustomAlertController alertFromStoryboard:@"NetworkAlert"];
    }
    
    [alert showAlert];
}

+ (void) showRedeemAlertWithTitle:(NSString*)title
						 punches:(NSInteger)punches
						andBlock:(RPCustomAlertActionButtonBlock)block
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"RedeemAlert"];
    alert.titleLabel.text = title ;

    alert.label2.text = [NSString stringWithFormat:@"%d %@", punches , punches == 1 ? @"Punch" : @"Punches"];
	alert.alertBlock = block;
	
    [alert showAsAction];
}


+ (void)showDecisionAlertWithTitle:(NSString*)title
						andMessage:(NSString*)message
					   andBlock:(RPCustomAlertActionButtonBlock)block
{
	RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:@"DecisionAlert"];
    alert.titleLabel.text = NSLocalizedString(title, nil);
    alert.label1.text = NSLocalizedString(message, nil);
	
    CGRect frame = [RPCustomAlertController frameForViewWithInitialFrame:alert.view.frame
													   withDynamicLabels:@[alert.titleLabel, alert.label1]
														andInitialHights:@[@(CGRectGetHeight(alert.titleLabel.frame)),
																		   @(CGRectGetHeight(alert.label1.frame))]];
    alert.view.frame = frame;
	alert.alertBlock = block;
	
	[alert showAlert];
}


+ (void)showDeleteMessageAlertWithBlock:(RPCustomAlertActionButtonBlock)block
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"DeleteMessageAlert"];
    alert.alertBlock  = block;

    [alert showAsAction];
}

+ (void)showDeleteMyPlaceAlertWithBlock:(RPCustomAlertActionButtonBlock)block
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"DeleteStoreAlert"];
    alert.alertBlock = block;
	
    [alert showAsAction];
}

+ (void)showCreateMessageAlertWithRecepient:(NSString*)recepient andBlock:(RPCustomAlertActionButtonBlock)block;
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"PostAlert"];
	
    alert.alertBlock  = block;
    alert.label1.text = recepient;
    alert.postTextView.delegate = alert;
	[alert.postTextView becomeFirstResponder];

    alert.sendButton.enabled = NO;

    [alert showAlert];
}

+ (void)showCreateGiftMessageAlertWithRecepient:(NSString*)recepient
									rewardTitle:(NSString*)rewardTitle
									   andBlock:(RPCustomAlertActionButtonBlock)block;
{
    RPCustomAlertController * alert = [RPCustomAlertController actionForIdentifier:@"GiftPostAlert"];

    alert.alertBlock  = block;
    alert.sendButton.enabled = NO;
    alert.label1.text = recepient;
    alert.label2.text = rewardTitle;
    alert.postTextView.delegate = alert;
	[alert.postTextView becomeFirstResponder];

    [alert showAlert];
}

+ (instancetype)actionForIdentifier:(NSString*)name;
{
    RPCustomAlertController * alert = [RPCustomAlertController alertFromStoryboard:name];
    alert.titleLabel.layer.cornerRadius = 4;
    alert.closeButton.layer.cornerRadius = 4;

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

- (IBAction)close:(UIButton *)sender
{
    [self hideAlertWithBlock:nil];
}

- (IBAction)actionButton:(UIButton *)sender
{
    RPCustomAlertActionButton button = NoneButton;
    id anObject = nil;

    if (self.redeemButton == sender) {
        button = RedeemButton;
    }
    else if (self.giftButton == sender) {
        button = GiftButton;
    }
    else if (self.deleteButton == sender) {
        button = DeleteButton;
    }
    else if (self.sendButton == sender) {
        button = SendButton;
        anObject = self.postTextView.text;
    }
    else if (self.confirmButton == sender) {
        button = ConfirmButton;
    }
	else if (self.denyButton == sender) {
        button = DenyButton;
    }

    if (self.alertBlock) {
        self.alertBlock(self, button, anObject);
    }
}


+ (CGRect)frameForViewWithInitialFrame:(CGRect)viewInitialFrame
					 withDynamicLabels:(NSArray*)labels
					  andInitialHights:(NSArray*)initialHeights
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSMutableString *string = [textView.text mutableCopy];
    [string replaceCharactersInRange:range withString:text];

    return  string.length <= MAX_BODY_LENGTH;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    self.postCharCount.text = [@(MAX_BODY_LENGTH - self.postTextView.text.length) stringValue];

    if (self.postTextView.text.length > 0) {
        self.sendButton.enabled = YES;
    }
    else{
        self.sendButton.enabled = NO;

    }
}

@end
