//
//  IncomingMessageViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeMessageViewController.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RPConstants.h"
#import "RPButton.h"
#import "RPPopupButton.h"
#import "RPTableView.h"

@class IncomingMessageViewController;

@protocol IncomingMessageVCDelegate <NSObject>
- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(RPMessageStatus *)msgStatus;
@end

@interface IncomingMessageViewController : UIViewController

@property (nonatomic, weak) id <IncomingMessageVCDelegate> delegate;
@property (strong, nonatomic) NSString *messageStatusId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet RPPopupButton *replyButton;
- (IBAction)replyButtonAction:(id)sender;

// Original Message
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *sender;
@property (weak, nonatomic) IBOutlet UILabel *sendDate;
@property (weak, nonatomic) IBOutlet UILabel *body;

// Offer/Gift
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UILabel *attachmentTitle;
@property (weak, nonatomic) IBOutlet UILabel *attachmentItem;
@property (weak, nonatomic) IBOutlet UILabel *attachmentDescription;
@property (weak, nonatomic) IBOutlet RPButton *redeemButton;

- (IBAction)redeemButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentTitleSuperviewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentViewSuperviewVerticalSpace;

// Reply
@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet UILabel *replySender;
@property (weak, nonatomic) IBOutlet UILabel *replySendDate;
@property (weak, nonatomic) IBOutlet UILabel *replyBody;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyViewSuperviewVerticalSpace;

@end
