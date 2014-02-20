//
//  IncomingMessageViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeMessageViewController.h"
#import "SIAlertView.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RPConstants.h"
#import "RPButton.h"
#import "RPTableView.h"

@class IncomingMessageViewController;

@protocol IncomingMessageVCDelegate <NSObject>
- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(RPMessageStatus *)msgStatus;
@end

@interface IncomingMessageViewController : UIViewController<ComposeMessageDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) id <IncomingMessageVCDelegate> delegate;

@property (strong, nonatomic) NSString *messageStatusId;

@property (weak, nonatomic) IBOutlet RPTableView *tableView;

//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;

// Original Message
//@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
//@property (weak, nonatomic) IBOutlet UILabel *sendTimeLabel;
//@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
/*
// Attachment (gift/offer)
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UIView *attachmentViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *attachmentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachmentItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachmentDescriptionLabel;
@property (weak, nonatomic) IBOutlet RPButton *redeemButton;


// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentTitleVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyBodyHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentHeightConstraint;

- (IBAction)redeemButtonAction:(id)sender;


// Reply
@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet UILabel *replySenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *replyBodyTextView;
 */

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
- (IBAction)replyButtonAction:(id)sender;

@end
