//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"
#import "OfferBorderView.h"
#import "GiftBorderView.h"

@implementation IncomingMessageViewController
{
	BOOL containsReply;
	UIActivityIndicatorView *attachmentSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = self.sharedData.patron;
	self.messageStatus = [self.sharedData getMessage:self.messageStatusId];
	self.message = self.messageStatus[@"Message"];
	self.reply = self.message[@"Reply"];
	self.messageType = self.message[@"message_type"];
	
	containsReply = ( !IS_NIL(self.reply) );
	
	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_icon"]
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(deleteButtonAction)];
	self.navigationItem.rightBarButtonItem = deleteButton;
	
	[self setupMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    if( [self.messageType isEqualToString:@"offer"] )
	{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
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
	
	if(self.timer != nil) {
		[self.timer invalidate];
	}
}

- (void)setupMessage
{
	if(containsReply) {
		NSString *title = [NSString stringWithFormat:@"RE: %@", self.message[@"subject"]];
		self.subjectLabel.text = title;
	}
	else {
		self.subjectLabel.text = self.message[@"subject"];
	}
	
    self.sendTimeLabel.text = [self formattedDateString:self.message.createdAt];
	self.senderLabel.text = self.message[@"sender_name"];
	self.bodyTextView.text = self.message[@"body"];
	self.bodyHeightConstraint.constant = self.bodyTextView.contentSize.height;
	
	[self.bodyTextView setNeedsLayout];
	[self.bodyTextView layoutIfNeeded];
	
	if ([self.messageType isEqualToString:@"offer"]) {
		self.navigationItem.title = @"Offer";
		[self setupOffer];
    }
    else if ([self.messageType isEqualToString:@"gift"]) {
		self.navigationItem.title = @"Gift";
        [self setupGift];
    }
	else {
		self.navigationItem.title = @"Message";
		self.attachmentView.hidden = YES;
	}
	
	if(containsReply) {
		[self setupReply];
	}
	else {
		self.replyView.hidden = YES;
	}

	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
}

- (void)setupOffer
{
	self.attachmentTitleVerticalConstraint.constant = 26.0f;
	
	self.attachmentTitleLabel.text = @"Offer";
	self.attachmentItemLabel.text = self.message[@"offer_title"];
	
	self.replyButton.hidden = YES;
	
	[self.attachmentView setNeedsLayout];
	[self.attachmentView layoutIfNeeded];
	
	OfferBorderView *background = [[OfferBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
}

- (void)setupGift
{
	self.attachmentTitleVerticalConstraint.constant = 80.0f;
	
	NSString *storeId = self.message[@"store_id"];
	RPStore *store = [self.sharedData getStore:storeId];
	
	self.attachmentItemLabel.text = self.message[@"gift_title"];
	self.attachmentDescriptionLabel.text = self.message[@"gift_description"];
	self.attachmentDescriptionLabel.font = [RepunchUtils repunchFontWithSize:17 isBold:NO];
	
	if(store)
	{
		self.attachmentTitleLabel.text = store.store_name;
	}
	else
	{
		attachmentSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		attachmentSpinner.frame = self.attachmentTitleLabel.bounds;
		[self.attachmentTitleLabel addSubview:attachmentSpinner];
		attachmentSpinner.hidesWhenStopped = YES;
		[attachmentSpinner startAnimating];
		
		PFQuery *query = [RPStore query];
		[query getObjectInBackgroundWithId:storeId block:^(PFObject *result, NSError *error) {
			if(result)
			{
				RPStore *resultStore = (RPStore *)result;
				[attachmentSpinner stopAnimating];
				[self.sharedData addStore:resultStore];
				self.attachmentTitleLabel.text = resultStore.store_name;
			}
			else
			{
				[RepunchUtils showConnectionErrorDialog];
			}
		}];
	}
	
	self.replyButton.hidden = containsReply;
	
	[self.attachmentView setNeedsLayout];
	[self.attachmentView layoutIfNeeded];
	
	GiftBorderView *background = [[GiftBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
}

- (void)setupReply
{
	self.replySenderLabel.text = self.reply[@"sender_name"];
    self.replyTimeLabel.text = [self formattedDateString:self.reply.createdAt];
	self.replyBodyTextView.text = self.reply[@"body"];
	self.replyBodyHeightConstraint.constant = self.replyBodyTextView.contentSize.height;
	
	[self.replyBodyTextView setNeedsLayout];
	[self.replyBodyTextView layoutIfNeeded];
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
    NSDate *offer = self.message[@"date_offer_expiration"];
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeLeft = [offer timeIntervalSinceDate:currentDate];
    self.attachmentDescriptionLabel.text = [NSString stringWithFormat:@"Time Left: %@", [self stringFromInterval:timeLeft]];
    
    if (timeLeft <= 0)
	{
        self.attachmentDescriptionLabel.text = @"Expired";
        self.timer = nil;
		
		//[RepunchUtils setDisabledButtonStyle:self.redeemButton];
		self.attachmentDescriptionLabel.enabled = NO;
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
	
	if(self.timer == nil && ![self.messageType isEqualToString:@"gift"]) { //timer is nil when it expires.
		return;
	}
	
	if( [self.messageStatus[@"redeem_available"] isEqualToString:@"yes"] )
	{
		self.redeemButton.enabled = NO;
		
		NSString *storeId = self.message[@"store_id"];
		NSString *patronStoreId = [[self.sharedData getPatronStore:storeId] objectId];
		
		if(patronStoreId == nil) {
			patronStoreId = (id)[NSNull null];
		}
		
		NSString *rewardTitle = [self.messageType isEqualToString:@"offer"] ?
		self.message[@"offer_title"] : self.message[@"gift_title"];
		NSString *customerName = [NSString stringWithFormat:@"%@ %@", self.patron[@"first_name"],
								  self.patron[@"last_name"]];
		
		NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
									self.patron.objectId,			@"patron_id",
									storeId,							@"store_id",
									patronStoreId,					@"patron_store_id",
									rewardTitle,						@"title",
									customerName,					@"name",
									self.messageStatus.objectId,		@"message_status_id",
									nil];
		
		[PFCloud callFunctionInBackground: @"request_redeem"
						   withParameters:parameters
									block:^(NSString *result, NSError *error)
		 {
			 self.redeemButton.enabled = YES;
			 
			 if(!error)
			 {
				 [self.messageStatus setObject:@"pending" forKey:@"redeem_available"];
				 [RepunchUtils setDisabledButtonStyle:self.redeemButton];
				 [RepunchUtils showDialogWithTitle:@"Waiting for confirmation"
									   withMessage:@"Please wait for this item to be validated"];
			 }
			 else
			 {
				 NSLog(@"request_redeem error: %@", error);
				 [RepunchUtils showConnectionErrorDialog];
			 }
		 }];
		
	}
	else if( [self.messageStatus[@"redeem_available"] isEqualToString:@"pending"] )
	{
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
	
	NSString *storeId = [[self.sharedData getStore:self.message[@"store_id"]] objectId];
	
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.delegate = self;
	composeVC.messageType = @"gift_reply";
	composeVC.storeId = storeId;
	composeVC.recepientName = self.message[@"sender_name"];
	composeVC.giftReplyMessageId = self.message.objectId;
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
	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Delete this message?" andMessage:nil];
	[alert addButtonWithTitle:@"Cancel"
							   type:SIAlertViewButtonTypeDefault
							handler:^(SIAlertView *alert) {
								[alert dismissAnimated:YES];
							}];
	
	
	[alert addButtonWithTitle:@"Delete"
							   type:SIAlertViewButtonTypeDestructive
							handler:^(SIAlertView *alert) {
								[self.sharedData removeMessage:self.messageStatusId];
								[self.delegate removeMessage:self forMsgStatus:self.messageStatus];
								[self.navigationController popViewControllerAnimated:NO];
								[alert dismissAnimated:YES];
							}];
	[alert show];
}

- (void)giftReplySent:(ComposeMessageViewController *)controller
{
	self.reply = self.message[@"Reply"];
	containsReply = !IS_NIL(self.reply);
	[self setupMessage];
	[self.delegate removeMessage:self forMsgStatus:nil];
}

@end
