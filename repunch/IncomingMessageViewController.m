//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"
#import "OfferBorderView.h"
#import "GiftBorderView.h"
#import "RPCustomAlertController.h"

@implementation IncomingMessageViewController
{
	DataManager *sharedData;
	NSString *messageType;
	RPMessageStatus *messageStatus;
	RPMessage *message;
	RPPatron *patron;
	NSTimer *timer;
	BOOL containsReply;
	UIActivityIndicatorView *attachmentSpinner;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [DataManager getSharedInstance];
	patron = sharedData.patron;
	messageStatus = [sharedData getMessage:self.messageStatusId];
	message = messageStatus.Message;
	messageType = message.message_type;
	
	containsReply = ( !IS_NIL(message.Reply) );
	
	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_delete"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(deleteButtonAction)];
	self.navigationItem.rightBarButtonItem = deleteButton;
	
	[self setupMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    if( [messageType isEqualToString:@"offer"] ) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(updateTimer)
                                               userInfo:nil
                                                repeats:YES];
        
        [self updateTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if(timer != nil) {
		[timer invalidate];
	}
}


- (void)setupMessage
{
	if( !IS_NIL(message.subject) ) {
		self.subject.text = [NSString stringWithFormat:(containsReply ? @"RE: %@" : @"%@"), message.subject];
	}
	
    self.sendDate.text = [self formattedDateString:message.createdAt];
	self.sender.text = message.sender_name;
	self.body.text = message.body;
	
	[self.messageView setNeedsLayout];
	[self.messageView layoutIfNeeded];
	
	if ([messageType isEqualToString:@"offer"]) {
		self.navigationItem.title = @"Offer";
		[self setupOffer];
    }
    else if ([messageType isEqualToString:@"gift"]) {
		self.navigationItem.title = @"Gift";
        [self setupGift];
    }
	else {
		self.navigationItem.title = @"Message";
		self.attachmentView.hidden = YES;
	}
	
	if(containsReply) {
		self.replySender.text = message.Reply.sender_name;
		self.replySendDate.text = [self formattedDateString:message.Reply.createdAt];
		self.replyBody.text = message.Reply.body;
		
		[self.replyView setNeedsLayout];
		[self.replyView layoutIfNeeded];
	}
	else {
		self.replyView.hidden = YES;
	}
	
	[self adjustConstraints];
}

- (void)setupOffer
{
	self.attachmentTitleSuperviewVerticalSpace.constant = 26.0f;
	
	self.attachmentTitle.text = @"Offer";
	self.attachmentItem.text = message.offer_title;
	
	if([messageStatus.redeem_available isEqualToString:@"yes"]) {
		[self.redeemButton setEnabled];
	} else {
		[self.redeemButton setDisabled];
	}
	
	[self.attachmentView setNeedsLayout];
	[self.attachmentView layoutIfNeeded];
	
	OfferBorderView *background = [[OfferBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
	[self.attachmentView sendSubviewToBack:background];
}

- (void)setupGift
{
	self.attachmentTitleSuperviewVerticalSpace.constant = 80.0f;
	
	self.attachmentItem.text = message.gift_title;
	self.attachmentDescription.text = message.gift_description;
	self.attachmentDescription.font = [RepunchUtils repunchFontWithSize:17 isBold:NO];
	
	RPStore *store = [sharedData getStore:message.store_id];
 
	if(store) {
		self.attachmentTitle.text = store.store_name;
	}
	else {
		attachmentSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		attachmentSpinner.frame = self.attachmentTitle.bounds;
		[self.attachmentTitle addSubview:attachmentSpinner];
		attachmentSpinner.hidesWhenStopped = YES;
		[attachmentSpinner startAnimating];
		
		PFQuery *query = [RPStore query];
		[query getObjectInBackgroundWithId:message.store_id block:^(PFObject *result, NSError *error) {
			
			if(result) {
				RPStore *resultStore = (RPStore *)result;
				[attachmentSpinner stopAnimating];
				[sharedData addStore:resultStore];
				self.attachmentTitle.text = resultStore.store_name;
			}
			else {
				[RepunchUtils showConnectionErrorDialog];
			}
		}];
	}
	
	// Show reply button if there is no reply
	if(containsReply) {
		self.replyButton.hidden = YES;
	} else {
		[self.replyButton showButton];
	}
	
	// Disable redeem button if pending or already redeemed
	if([messageStatus.redeem_available isEqualToString:@"yes"]) {
		[self.redeemButton setEnabled];
	} else {
		[self.redeemButton setDisabled];
	}
	
	// Hide redeem button if user was the gift sender
	if([message.patron_id isEqualToString:patron.objectId]) {
		[self.redeemButton removeFromSuperview];
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.attachmentView
																	  attribute:NSLayoutAttributeBottom
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:self.attachmentDescription
																	  attribute:NSLayoutAttributeBottom
																	 multiplier:1
																	   constant:40];
		[self.attachmentView addConstraint:constraint];
	}
	
	[self.attachmentView setNeedsLayout];
	[self.attachmentView layoutIfNeeded];
	
	GiftBorderView *background = [[GiftBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
	[self.attachmentView sendSubviewToBack:background]; //needs to be behind redeem button
}

- (void)adjustConstraints
{
	if([messageType isEqualToString:@"offer"] || [messageType isEqualToString:@"gift"]) {
		self.attachmentViewSuperviewVerticalSpace.constant = self.messageView.frame.size.height;
	}
	
	if(containsReply) {
		if([messageType isEqualToString:@"offer"] || [messageType isEqualToString:@"gift"]) {
			CGRect attachmentFrame = self.attachmentView.frame;
			self.replyViewSuperviewVerticalSpace.constant = attachmentFrame.origin.y + attachmentFrame.size.height;
		}
		else {
			CGRect messageFrame = self.messageView.frame;
			self.replyViewSuperviewVerticalSpace.constant = messageFrame.origin.y + messageFrame.size.height;
		}
	}
	
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
	
	NSLayoutConstraint *constraint;
	
	if(containsReply) {
		constraint = [NSLayoutConstraint constraintWithItem:self.scrollView
												  attribute:NSLayoutAttributeBottom
												  relatedBy:NSLayoutRelationEqual
													 toItem:self.replyView
												  attribute:NSLayoutAttributeBottom
												 multiplier:1
												   constant:30];
	}
	else if([messageType isEqualToString:@"offer"] || [messageType isEqualToString:@"gift"]){
		constraint = [NSLayoutConstraint constraintWithItem:self.scrollView
												  attribute:NSLayoutAttributeBottom
												  relatedBy:NSLayoutRelationEqual
													 toItem:self.attachmentView
												  attribute:NSLayoutAttributeBottom
												 multiplier:1
												   constant:70];
	}
	else {
		constraint = [NSLayoutConstraint constraintWithItem:self.scrollView
												  attribute:NSLayoutAttributeBottom
												  relatedBy:NSLayoutRelationEqual
													 toItem:self.messageView
												  attribute:NSLayoutAttributeBottom
												 multiplier:1
												   constant:30];
	}
	
	[self.scrollView addConstraint:constraint];
	
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
}

#pragma mark - Helper Methods

 - (NSString *)formattedDateString:(NSDate *)dateCreated
{
     NSCalendar *cal = [NSCalendar currentCalendar];
     NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
     NSDate *today = [cal dateFromComponents:components];
     components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dateCreated];
     NSDate *otherDate = [cal dateFromComponents:components];
     
     NSLocale *locale = [NSLocale currentLocale];
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     
     if([today isEqualToDate:otherDate])
	 {
         [formatter setDateFormat:@"hh:mm a"];
         [formatter setLocale:locale];
         [formatter setTimeZone:[NSTimeZone localTimeZone]];
     }
	 else
	 {
         [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd" options:0 locale:locale]];
         [formatter setLocale:locale];
     }
     
     return [formatter stringFromDate:dateCreated];
}

- (void)updateTimer
{
    NSDate *offer = message.date_offer_expiration;
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeLeft = [offer timeIntervalSinceDate:currentDate];
    self.attachmentDescription.text = [NSString stringWithFormat:@"Time Left: %@", [self stringFromInterval:timeLeft]];
    
    if (timeLeft <= 0)
	{
        self.attachmentDescription.text = @"Expired";
        timer = nil;
		
		[self.redeemButton setDisabled];
    }
}

- (NSString *)stringFromInterval:(NSTimeInterval)timeInterval
{
	int SECONDS_IN_MINUTE = 60;
    int SECONDS_IN_HOUR = 60*60;
    int SECONDS_IN_DAY = 24*60*60;
    
    // convert the time to an integer, as we don't need double precision,
	// and we do need to use the modulous operator
    int ti = round(timeInterval);
	
	int days = ti/SECONDS_IN_DAY;
	int hours = (ti - days*SECONDS_IN_DAY)/SECONDS_IN_HOUR;
	int minutes = (ti - days*SECONDS_IN_DAY - hours*SECONDS_IN_HOUR)/SECONDS_IN_MINUTE;
	int seconds = (ti - days*SECONDS_IN_DAY - hours*SECONDS_IN_HOUR - minutes*SECONDS_IN_MINUTE);
	
	if(days > 1) {
		return [NSString stringWithFormat:@"%i days, %.2d:%.2d:%.2d", days, hours, minutes, seconds];
	} else if(days == 1) {
		return [NSString stringWithFormat:@"1 day, %.2d:%.2d:%.2d", hours, minutes, seconds];
	} else {
		return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
	}
}

- (IBAction)redeemButtonAction:(id)sender
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(timer == nil && ![messageType isEqualToString:@"gift"]) { //timer is nil when it expires.
		return;
	}
	
	if( [messageStatus.redeem_available isEqualToString:@"yes"] ) {
		
		NSString *patronStoreId = [[sharedData getPatronStore:message.store_id] objectId];
		
		if(patronStoreId == nil) {
			patronStoreId = (id)[NSNull null];
		}
		
		NSString *rewardTitle = [messageType isEqualToString:@"offer"] ?
		message.offer_title : message.gift_title;
		
		NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
									patron.objectId,				@"patron_id",
									message.store_id,				@"store_id",
									patronStoreId,					@"patron_store_id",
									rewardTitle,					@"title",
									patron.full_name,				@"name",
									messageStatus.objectId,			@"message_status_id",
									nil];
		
		self.redeemButton.enabled = NO;
		[self.redeemButton startSpinner];
		
		[PFCloud callFunctionInBackground: @"request_redeem"
						   withParameters:parameters
									block:^(NSString *result, NSError *error) {

			self.redeemButton.enabled = YES;
			[self.redeemButton stopSpinner];
			 
			 if(!error) {
				 [messageStatus setObject:@"pending" forKey:@"redeem_available"];
				 [self.redeemButton setDisabled];
				 [RepunchUtils showDialogWithTitle:@"Waiting for confirmation"
									   withMessage:@"Please wait for this item to be validated"];
			 }
			 else {
				 NSLog(@"request_redeem error: %@", error);
				 [RepunchUtils showConnectionErrorDialog];
			 }
		 }];
		
	}
	else if( [messageStatus.redeem_available isEqualToString:@"pending"] ) {
		[RepunchUtils showDialogWithTitle:@"Offer pending"
							  withMessage:@"You can only request this item once"];
	}
	else
	{
		[RepunchUtils showDialogWithTitle:@"Offer redeemed"
							  withMessage:@"You have already redeemed this item"];
	}
}

- (IBAction)replyButtonAction:(id)sender
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.delegate = self;
	composeVC.messageType = @"gift_reply";
	composeVC.storeId = message.store_id;
	composeVC.recepientName = message.sender_name;
	composeVC.giftReplyMessageId = message.objectId;
	composeVC.giftMessageStatusId = self.messageStatusId;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:composeVC];
	[RepunchUtils setupNavigationController:navController];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)deleteButtonAction
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}

    [RPCustomAlertController showDeleteMessageAlertWithBlock:^(RPCustomAlertActionButton buttonType, id anObject) {

        if (buttonType == DeleteButton) {
            [sharedData removeMessage:self.messageStatusId];
            [self.delegate removeMessage:self forMsgStatus:messageStatus];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }];

}

- (void)giftReplySent:(ComposeMessageViewController *)controller
{
	containsReply = !IS_NIL(message.Reply);
	[self.replyButton hideButton];
	[self setupMessage];
	[self.delegate removeMessage:self forMsgStatus:nil];
}

@end
