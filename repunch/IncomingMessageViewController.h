//
//  MessageAutoLayoutViewController.h
//  repunch
//
//  Created by Gwendolyn Weston on 7/22/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface IncomingMessageViewController : UIViewController

//VIEW DATA SOURCE
@property (nonatomic, retain) NSString *messageStatusId;
@property (nonatomic, retain) PFObject *message;
@property (nonatomic, retain) PFObject *messageStatus;
@property (nonatomic, retain) NSString *messageType;
@property (nonatomic, retain) NSString *customerName;

//VIEW UI LABELS + ACTNS
@property (weak, nonatomic) IBOutlet UIView *toolbar;

//Toolbar methods + labels
@property (weak, nonatomic) IBOutlet UILabel *messageHeader;
@property (weak, nonatomic) IBOutlet UIButton *replyToMessageLbl;

- (IBAction)replyToMessageActn:(id)sender;
- (IBAction)deleteMessageActn:(id)sender;
- (IBAction)closeSettingActn:(id)sender;

//Received Message labels
@property (weak, nonatomic) IBOutlet UILabel *senderNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateSentLbl;
@property (weak, nonatomic) IBOutlet UITextView *sentBodyLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sentBodyHeightConstraint;


//Offer labels
@property (weak, nonatomic) IBOutlet UIButton *offerLbl;
@property (weak, nonatomic) IBOutlet UILabel *offerTimeLeftLbl;
@property (weak, nonatomic) IBOutlet UILabel *offerCountdownLbl;
@property (weak, nonatomic) IBOutlet UIView *offerView;

- (IBAction)redeemOfferActn:(id)sender;

//Reply Message labels
@property (weak, nonatomic) IBOutlet UILabel *replyNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateRepliedLbl;
@property (weak, nonatomic) IBOutlet UITextView *repliedBodyLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repliedBodyHeightLayout;

@property (weak, nonatomic) IBOutlet UIView *responseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtwnMessageAndResponse;


@end
