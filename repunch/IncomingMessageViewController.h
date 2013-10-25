//
//  IncomingMessageViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeMessageViewController.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RPConstants.h"

@class IncomingMessageViewController;

@protocol IncomingMessageVCDelegate <NSObject>
- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(PFObject *)msgStatus;
@end

@interface IncomingMessageViewController : UIViewController<ComposeMessageDelegate>

@property (nonatomic, weak) id <IncomingMessageVCDelegate> delegate;

@property (strong, nonatomic) DataManager *sharedData;
@property (strong, nonatomic) PFObject *patron;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *messageType;
@property (strong, nonatomic) NSString *messageStatusId;
@property (strong, nonatomic) PFObject *messageStatus;
@property (strong, nonatomic) PFObject *message;
@property (strong, nonatomic) PFObject *reply;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// Original Message
//@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

// Attachment (gift/offer)
@property (strong, nonatomic) IBOutlet UIView *giftView;
@property (weak, nonatomic) IBOutlet UILabel *giftHeader;
@property (weak, nonatomic) IBOutlet UILabel *giftTitle;
@property (weak, nonatomic) IBOutlet UIButton *giftButton;
@property (weak, nonatomic) IBOutlet UILabel *giftTimerLabel;
@property (weak, nonatomic) IBOutlet UIButton *giftReplyButton;

- (IBAction)giftButtonAction:(id)sender;
- (IBAction)giftReplyButtonAction:(id)sender;

// Reply
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet UILabel *replySenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *replyBodyTextView;


@end
