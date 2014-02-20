//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"
#import "MessageTableViewCell.h"
#import "AttachmentTableViewCell.h"
#import "OfferBorderView.h"
#import "GiftBorderView.h"

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

- (id)init
{
    self = [super initWithNibName:@"IncomingMessageViewController" bundle:nil];
    if (self) {

    }
    return self;
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
	
	//[[NSBundle mainBundle] loadNibNamed:@"AttachmentView" owner:self options:nil];
	
	//[self setupMessage];
	if ([messageType isEqualToString:@"offer"]) {
		self.navigationItem.title = @"Offer";
    }
    else if ([messageType isEqualToString:@"gift"]) {
		self.navigationItem.title = @"Gift";
    }
	else {
		self.navigationItem.title = @"Message";
	}

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    if( [messageType isEqualToString:@"offer"] )
	{
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

/*
- (void)setupMessage
{
	if( !IS_NIL(message.subject) ) {
		self.subjectLabel.text = containsReply ? [NSString stringWithFormat:@"RE: %@", message.subject] :
													message.subject;
	}
	
    self.sendTimeLabel.text = [self formattedDateString:message.createdAt];
	self.senderLabel.text = message.sender_name;
	self.bodyTextView.text = message.body;
	[self.bodyTextView sizeToFit];
	
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
		[self setupReply];
	}
	else {
		self.replyView.hidden = YES;
	}
	
	if ( [messageType isEqualToString:@"offer"] || [messageType isEqualToString:@"gift"] ) {
		[self.attachmentViewContainer addSubview:self.attachmentView];
		self.attachmentView.center = self.attachmentViewContainer.center;
		self.attachmentHeightConstraint.constant = self.attachmentView.frame.size.height + 50;
    }
	else {
		self.attachmentHeightConstraint.constant = 0;
	}
	
	[self.scrollView setNeedsLayout];
	[self.scrollView layoutIfNeeded];
	
	self.bodyHeightConstraint.constant = self.bodyTextView.contentSize.height;
	self.replyBodyHeightConstraint.constant = self.bodyTextView.contentSize.height;
}

- (void)setupOffer
{
	self.attachmentTitleVerticalConstraint.constant = 26.0f;
	
	self.attachmentTitleLabel.text = @"Offer";
	self.attachmentItemLabel.text = message.offer_title;
	
	[self.attachmentView setNeedsLayout];
	[self.attachmentView layoutIfNeeded];
	
	OfferBorderView *background = [[OfferBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
}

- (void)setupGift
{
	self.attachmentTitleVerticalConstraint.constant = 80.0f;
	
	self.attachmentItemLabel.text = message.gift_title;
	self.attachmentDescriptionLabel.text = message.gift_description;
	self.attachmentDescriptionLabel.font = [RepunchUtils repunchFontWithSize:17 isBold:NO];
	
	RPStore *store = [sharedData getStore:message.store_id];
 
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
		[query getObjectInBackgroundWithId:message.store_id block:^(PFObject *result, NSError *error) {
			if(result)
			{
				RPStore *resultStore = (RPStore *)result;
				[attachmentSpinner stopAnimating];
				[sharedData addStore:resultStore];
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
	
	[self.redeemButton setNeedsLayout];
	[self.redeemButton layoutIfNeeded];
	
	CGRect frame = self.attachmentView.frame;
	frame.size.height = self.redeemButton.frame.origin.y + self.redeemButton.frame.size.height + 30.0f;
	self.attachmentView.frame = frame;
	
	GiftBorderView *background = [[GiftBorderView alloc] init];
	background.frame = self.attachmentView.bounds;
	[self.attachmentView addSubview:background];
}

- (void)setupReply
{
	self.replySenderLabel.text = message.Reply.sender_name;
    self.replyTimeLabel.text = [self formattedDateString:message.Reply.createdAt];
	self.replyBodyTextView.text = message.Reply.body;
	[self.replyBodyTextView sizeToFit];
}
*/

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 1;
	if(containsReply) {
		++rows;
	}
	if([messageType isEqualToString:@"offer"] || [messageType isEqualToString:@"gift"]) {
		++rows;
	}
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageTableViewCell class]]) {
        return [((MessageTableViewCell*)cell) height];
    }
    return 400;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == 0)
	{
		MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
		
		if (cell == nil) {
			cell = [MessageTableViewCell cell];
		}
		
		if( !IS_NIL(message.subject) ) {
			cell.subject.text = containsReply ? [NSString stringWithFormat:@"RE: %@", message.subject] :
			message.subject;
		}
		else {
			cell.subject.text = nil;
		}
		
		cell.senderName.text = message.sender_name;
		cell.sendTime.text = [self formattedDateString:message.createdAt];
		cell.body.text = message.body;

		return cell;
	}
	else if(indexPath.row == 1 && [messageType isEqualToString:@"offer"])
	{
		AttachmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachment"];
		
		if (cell == nil) {
			cell = [AttachmentTableViewCell cell];
		}
		
		cell.title.text = @"Offer";
		cell.rewardTitle.text = message.offer_title;
		cell.rewardDescription.text = @"Timer goes here";
		
		[cell setOfferBorder];
    
		
		return cell;
	}
	else if(indexPath.row == 1 && [messageType isEqualToString:@"gift"])
	{
		AttachmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attachment"];
		
		if (cell == nil) {
			cell = [AttachmentTableViewCell cell];
		}
		
		cell.title.text = message.store_id;
		cell.rewardTitle.text = message.gift_title;
		cell.rewardDescription.text = message.gift_description;
		
		[cell setGiftBorder];
		
		return cell;
	}
	else // Reply
	{
		MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reply"];
		
		if (cell == nil) {
			cell = [MessageTableViewCell cell];
		}
		
		cell.subject.text = nil;
		cell.senderName.text = message.Reply.sender_name;
		cell.sendTime.text = [self formattedDateString:message.Reply.createdAt];
		cell.body.text = message.Reply.body;

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
    //self.attachmentDescriptionLabel.text = [NSString stringWithFormat:@"Time Left: %@", [self stringFromInterval:timeLeft]];
    
    if (timeLeft <= 0)
	{
        //self.attachmentDescriptionLabel.text = @"Expired";
        timer = nil;
		
		//[RepunchUtils setDisabledButtonStyle:self.redeemButton];
		//self.attachmentDescriptionLabel.enabled = NO;
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
	
	if( [messageStatus.redeem_available isEqualToString:@"yes"] )
	{
		//self.redeemButton.enabled = NO;
		
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
		
		[PFCloud callFunctionInBackground: @"request_redeem"
						   withParameters:parameters
									block:^(NSString *result, NSError *error)
		 {
			 //self.redeemButton.enabled = YES;
			 
			 if(!error)
			 {
				 [messageStatus setObject:@"pending" forKey:@"redeem_available"];
				 //[self.redeemButton setDisabled];
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
	else if( [messageStatus.redeem_available isEqualToString:@"pending"] )
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
	
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Delete this message?" andMessage:nil];
	[alert addButtonWithTitle:@"Cancel"
							   type:SIAlertViewButtonTypeDefault
							handler:^(SIAlertView *alert) {
								[alert dismissAnimated:YES];
							}];
	
	
	[alert addButtonWithTitle:@"Delete"
							   type:SIAlertViewButtonTypeDestructive
							handler:^(SIAlertView *alert) {
								[sharedData removeMessage:self.messageStatusId];
								[self.delegate removeMessage:self forMsgStatus:messageStatus];
								[self.navigationController popViewControllerAnimated:NO];
								[alert dismissAnimated:YES];
							}];
	[alert show];
}

- (void)giftReplySent:(ComposeMessageViewController *)controller
{
	containsReply = !IS_NIL(message.Reply);
	//[self setupMessage];
	[self.delegate removeMessage:self forMsgStatus:nil];
}

@end
