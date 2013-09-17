//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"

@implementation IncomingMessageViewController
{
	BOOL containsReply;
	UIActivityIndicatorView *giftSpinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tabBarController.tabBar.hidden = YES;
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = self.sharedData.patron;
	self.messageStatus = [self.sharedData getMessage:self.messageStatusId];
	self.message = [self.messageStatus objectForKey:@"Message"];
	self.reply = [self.message objectForKey:@"Reply"];
	self.messageType = [self.message objectForKey:@"message_type"];
	
	containsReply = (self.reply != (id)[NSNull null] && self.reply != nil);
	
	if(containsReply) {
		NSString *title = [NSString stringWithFormat:@"RE: %@", [self.message objectForKey:@"subject"]];
		self.navigationItem.title = title;
	} else {
		self.navigationItem.title = [self.message objectForKey:@"subject"];
	}
	
	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
					initWithImage:[UIImage imageNamed:@"nav_delete.png"]
					style:UIBarButtonItemStylePlain
					target:self
					action:@selector(deleteButtonAction:)];
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
	
	self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupMessage
{
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size.height = [[UIScreen mainScreen] applicationFrame].size.height
										- self.navigationController.navigationBar.frame.size.height;
    self.scrollView.frame = scrollViewFrame;
    
    self.dateLabel.text = [self formattedDateString:self.message.createdAt];
	self.senderLabel.text = [self.message objectForKey:@"sender_name"];
	self.bodyTextView.text = [self.message objectForKey:@"body"];
    CGRect frame = self.bodyTextView.frame;
    frame.size.height = self.bodyTextView.contentSize.height;
    self.bodyTextView.frame = frame;
	
	[self.bodyTextView sizeToFit];
	
	CGFloat contentHeight = frame.origin.y + frame.size.height;
	
	if ([self.messageType isEqualToString:@"offer"])
	{
		[self setupOffer];
		contentHeight = self.giftView.frame.origin.y + self.giftView.frame.size.height;
    }
    else if ([self.messageType isEqualToString:@"gift"])
	{
        [self setupGift];
		contentHeight = self.giftView.frame.origin.y + self.giftView.frame.size.height;
    }
	
	if(containsReply)
	{
		[self setupReply];
		contentHeight = self.replyView.frame.origin.y + self.replyView.frame.size.height;
	}
	
	self.scrollView.contentSize = CGSizeMake(320, contentHeight + 40);
}

- (void)setupReply
{
    [[NSBundle mainBundle] loadNibNamed:@"MessageReply" owner:self options:nil];
    
    self.replyDateLabel.text = [self formattedDateString:self.reply.createdAt];
	self.replySenderLabel.text = [self.reply objectForKey:@"sender_name"];
	self.replyBodyTextView.text = [self.reply objectForKey:@"body"];
	[self.replyBodyTextView sizeToFit];
	
    CGRect msgFrame = [self.messageType isEqualToString:@"gift"] ? self.giftView.frame : self.bodyTextView.frame;
    CGRect replyViewFrame = self.replyView.frame;
    
    replyViewFrame.origin.y = msgFrame.origin.y + msgFrame.size.height + 20;
	replyViewFrame.size.height = self.replyBodyTextView.frame.origin.y + self.replyBodyTextView.frame.size.height;
	self.replyView.frame = replyViewFrame;
	self.replyView.hidden = NO;
    
    [self.scrollView addSubview:self.replyView];
}

- (void)setupOffer
{
	[[NSBundle mainBundle] loadNibNamed:@"MessageAttachment" owner:self options:nil];
	
	self.giftHeader.text = @"Offer";
	self.giftTitle.text = [self.message objectForKey:@"offer_title"];
	
	[self positionAttachmentViews:NO];
	[self.scrollView addSubview:self.giftView];
}

- (void)setupGift
{
	[[NSBundle mainBundle] loadNibNamed:@"MessageAttachment" owner:self options:nil];
	
	NSString *storeId = [self.message objectForKey:@"store_id"];
	PFObject *store = [self.sharedData getStore:storeId];	
	
	self.giftTitle.text = [self.message objectForKey:@"gift_title"];
	self.giftTimerLabel.text = [self.message objectForKey:@"gift_description"];
	self.giftTimerLabel.font = [UIFont fontWithName:@"Avenir" size:17];
	
	if(store)
	{
		self.giftHeader.text = [store objectForKey:@"store_name"];
	}
	else
	{
		giftSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		giftSpinner.frame = self.giftHeader.bounds;
		[self.giftHeader addSubview:giftSpinner];
		giftSpinner.hidesWhenStopped = YES;
		[giftSpinner startAnimating];
		
		PFQuery *query = [PFQuery queryWithClassName:@"Store"];
		[query getObjectInBackgroundWithId:storeId block:^(PFObject *result, NSError *error)
		{
			if(result)
			{
				[giftSpinner stopAnimating];
				[self.sharedData addStore:result];
				self.giftHeader.text = [result objectForKey:@"store_name"];
			}
			else
			{
				[RepunchUtils showDefaultErrorMessage];
			}
		}];
	}
	
	[self positionAttachmentViews:YES];
	[self.scrollView addSubview:self.giftView];
}

- (void)positionAttachmentViews:(BOOL)isGift
{
	CGRect msgFrame = self.bodyTextView.frame;
    CGRect giftViewFrame = self.giftView.frame;
    giftViewFrame.origin.y = msgFrame.origin.y + msgFrame.size.height + 30;
    self.giftView.frame = giftViewFrame;
	
	[self.giftView.layer setCornerRadius:14];
	[self.giftView setClipsToBounds:YES];
	
	if( [[self.messageStatus objectForKey:@"redeem_available"] isEqualToString:@"yes"] )
	{
		[self.giftButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.giftButton]
										forState:UIControlStateNormal];
		[self.giftButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.giftButton]
										forState:UIControlStateHighlighted];
	}
	else
	{
		[self.giftButton setBackgroundImage:[GradientBackground greyDisabledButton:self.giftButton]
								   forState:UIControlStateNormal];
		[self.giftButton setBackgroundImage:[GradientBackground greyDisabledButton:self.giftButton]
								   forState:UIControlStateHighlighted];
	}
	
	[self.giftButton.layer setCornerRadius:5];
	[self.giftButton setClipsToBounds:YES];
	
	if(isGift)
	{
		if( [[self.message objectForKey:@"patron_id"] isEqualToString:self.patron.objectId] )
		{
			self.giftButton.hidden = YES;
			self.giftReplyButton.hidden = YES;
		}
		else if(!containsReply)
		{
			self.giftReplyButton.hidden = NO;
			[self.giftReplyButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.giftReplyButton]
												forState:UIControlStateNormal];
			[self.giftReplyButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.giftReplyButton]
												forState:UIControlStateHighlighted];
			[self.giftReplyButton.layer setCornerRadius:5];
			[self.giftReplyButton setClipsToBounds:YES];
		}
		else
		{
			self.giftReplyButton.hidden = YES;
			CGRect frame = self.giftButton.frame;
			frame.origin.x = (self.giftView.frame.size.width - frame.size.width)/2;
			self.giftButton.frame = frame;
		}
	}
	else
	{
		self.giftReplyButton.hidden = YES;
		CGRect frame = self.giftButton.frame;
		frame.origin.x = (self.giftView.frame.size.width - frame.size.width)/2;
		self.giftButton.frame = frame;
		
	}
	
	CGRect giftFrame = self.giftView.frame;
	CGRect titleFrame = self.giftTitle.frame;
	CGRect timerFrame = self.giftTimerLabel.frame;
	CGRect buttonFrame = self.giftButton.frame;
	CGRect replyButtonFrame = self.giftReplyButton.frame;
	
	[self.giftTitle sizeToFit];
	[self.giftTimerLabel sizeToFit];

	titleFrame.origin.y = self.giftHeader.frame.origin.y + self.giftHeader.frame.size.height + 25;
	titleFrame.size.height = self.giftTitle.frame.size.height;
	self.giftTitle.frame = titleFrame;
	
	timerFrame.origin.y = self.giftTitle.frame.origin.y + self.giftTitle.frame.size.height + 25;
	timerFrame.size.height = self.giftTimerLabel.frame.size.height;
	self.giftTimerLabel.frame = timerFrame;
	
	buttonFrame.origin.y = self.giftTimerLabel.frame.origin.y + self.giftTimerLabel.frame.size.height + 25;
	self.giftButton.frame = buttonFrame;
	
	replyButtonFrame.origin.y = buttonFrame.origin.y;
	self.giftReplyButton.frame = replyButtonFrame;
	
	if(isGift)
	{
		if( [[self.message objectForKey:@"patron_id"] isEqualToString:self.patron.objectId] ) {
			giftFrame.size.height = self.giftTimerLabel.frame.origin.y + self.giftTimerLabel.frame.size.height + 25;
		} else {
			giftFrame.size.height = self.giftButton.frame.origin.y + self.giftButton.frame.size.height + 25;
		}
	}
	else
	{
		giftFrame.size.height = self.giftButton.frame.origin.y + self.giftButton.frame.size.height + 25;
	}
	
	self.giftView.frame = giftFrame;
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
    NSDate *offer = [self.message objectForKey:@"date_offer_expiration"];
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval timeLeft = [offer timeIntervalSinceDate:currentDate];
    self.giftTimerLabel.text = [NSString stringWithFormat:@"Time Left: %@", [self stringFromInterval:timeLeft]];
    
    if (timeLeft <= 0)
	{
        self.giftTimerLabel.text = @"Expired";
        self.timer = nil;
		
		[self.giftButton setBackgroundImage:[GradientBackground greyDisabledButton:self.giftButton]
								   forState:UIControlStateNormal];
		self.giftButton.enabled = NO;
    }
}

-(NSString *)stringFromInterval:(NSTimeInterval)timeInterval
{
	int SECONDS_IN_MINUTE = 60;
    int SECONDS_IN_HOUR = 60*60;
    int SECONDS_IN_DAY = 24*60*60;
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
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

- (IBAction)giftButtonAction:(id)sender
{
	if(self.timer == nil && ![self.messageType isEqualToString:@"gift"]) { //timer is nil when it expires.
		return;
	}
	
	
	if( [[self.messageStatus objectForKey:@"redeem_available"] isEqualToString:@"yes"] )
	{
		self.giftButton.enabled = NO;
		
		NSString *storeId = [[self.sharedData getStore:[self.message objectForKey:@"store_id"]] objectId];
		NSString *patronStoreId = [[self.sharedData getPatronStore:storeId] objectId];
		NSString *rewardTitle = [self.messageType isEqualToString:@"offer"] ?
										[self.message objectForKey:@"offer_title"] : [self.message objectForKey:@"gift_title"];
		NSString *customerName = [NSString stringWithFormat:@"%@ %@", [self.patron objectForKey:@"first_name"],
								  [self.patron objectForKey:@"last_name"]];
	
		NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
								   self.patron.objectId,			@"patron_id",
								   storeId,							@"store_id",
								   patronStoreId,					@"patron_store_id",
								   rewardTitle,						@"title",
								   customerName,					@"name",
								   self.messageStatus.objectId,		@"message_status_id",
								   nil];
	
		[PFCloud callFunctionInBackground: @"request_redeem"
						   withParameters:inputArgs
									block:^(NSString *result, NSError *error)
		 {
			 self.giftButton.enabled = YES;
			 
			 if(!error)
			 {
				 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Waiting for confirmation"
															  andMessage:@"Please wait for this item to be validated"];
				 
				 [self.messageStatus setObject:@"pending" forKey:@"redeem_available"];
				 [self.giftButton setBackgroundImage:[GradientBackground greyDisabledButton:self.giftButton]
											forState:UIControlStateNormal];
				 [self.giftButton setBackgroundImage:[GradientBackground greyDisabledButton:self.giftButton]
											forState:UIControlStateHighlighted];
				 
				 [alert addButtonWithTitle:@"OK"
									  type:SIAlertViewButtonTypeDefault
								   handler:^(SIAlertView *alertView) {}];
				 [alert show];
			 }
			 else
			 {
				 NSLog(@"request_redeem error: %@", error);
				 [RepunchUtils showDefaultErrorMessage];
			 }
		 }];
		
	}
	else if( [[self.messageStatus objectForKey:@"redeem_available"] isEqualToString:@"pending"] )
	{
		SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Offer pending"
													 andMessage:@"You can only request this item once"];
		[alert addButtonWithTitle:@"OK"
							 type:SIAlertViewButtonTypeDefault
						  handler:^(SIAlertView *alertView) {}];
		[alert show];
	}
	else
	{
		SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Offer redeemed"
													 andMessage:@"You have already redeemed this item"];
		[alert addButtonWithTitle:@"OK"
							 type:SIAlertViewButtonTypeDefault
						  handler:^(SIAlertView *alertView) {}];
		[alert show];
	}
}

- (IBAction)giftReplyButtonAction:(id)sender
{	
	NSString *storeId = [[self.sharedData getStore:[self.message objectForKey:@"store_id"]] objectId];
	
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.delegate = self;
	composeVC.messageType = @"gift_reply";
	composeVC.storeId = storeId;
	composeVC.recepientName = [self.message objectForKey:@"sender_name"];
	composeVC.giftReplyMessageId = self.message.objectId;
	composeVC.giftMessageStatusId = self.messageStatusId;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:composeVC];
	[RepunchUtils setupNavigationController:navController];
	[self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)deleteButtonAction:(id)sender
{	
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
								[self dismissViewControllerAnimated:YES completion:nil];
								[alert dismissAnimated:YES];
							}];
	[alert show];
}

- (IBAction)closeButtonAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)giftReplySent:(ComposeMessageViewController *)controller
{
	self.reply = [self.message objectForKey:@"Reply"];
	containsReply = (self.reply != (id)[NSNull null] && self.reply != nil);
	[self.giftView removeFromSuperview];
	[self setupMessage];
	[self.delegate removeMessage:self forMsgStatus:nil];
}

- (void)showDialog:(NSString*)title withMessage:(NSString*)message
{
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title
                                                 andMessage:message];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

@end
