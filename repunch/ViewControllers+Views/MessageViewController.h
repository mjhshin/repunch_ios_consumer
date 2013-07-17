//
//  MessageViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import <Parse/Parse.h>

@interface MessageViewController : UIViewController <ModalDelegate>
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain)  PFObject *message; 
@property (nonatomic, retain)  PFObject *messageStatus; 
- (IBAction)closeMessage:(id)sender;
- (IBAction)deleteMessage:(id)sender;
- (IBAction)sendReply:(id)sender;

@property (nonatomic, retain) NSString *customerName;
@property (nonatomic, retain) NSString *patronId;

@property (weak, nonatomic) IBOutlet UILabel *messageName;
@property (nonatomic, retain) NSString *messageType;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *replierLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UITextView *replyBodyLabel;
@property (weak, nonatomic) IBOutlet UITextView *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *offerTitleBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
- (IBAction)redeemOffer:(id)sender;

@end
