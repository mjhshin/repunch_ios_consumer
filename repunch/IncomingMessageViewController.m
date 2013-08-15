//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"

@implementation IncomingMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.sharedData = [DataManager getSharedInstance];
	self.patron = self.sharedData.patron;
	self.messageStatus = [self.sharedData getMessage:_messageStatusId];
	self.message = [self.messageStatus objectForKey:@"Message"];
	self.reply = [self.message objectForKey:@"Reply"];
	self.messageType = [self.message objectForKey:@"message_type"];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	if(self.reply == [NSNull null]) {
		[self.messageTitle setText:[self.message objectForKey:@"subject"]];
	} else {
		NSString *title = [NSString stringWithFormat:@"RE: %@", [self.message objectForKey:@"subject"]];
		[self.messageTitle setText:title];
	}
	
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupMessage
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenHeight = screenRect.size.height;
	int toolBarHeight = self.toolbar.frame.size.height;

	CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size.height = screenHeight - toolBarHeight;
    self.scrollView.frame = scrollViewFrame;
    
    self.dateLabel.text = [self formattedDateString:self.message.createdAt];
	self.senderLabel.text = [self.message objectForKey:@"sender_name"];
	self.bodyTextView.text = [self.message objectForKey:@"body"];
    CGRect frame = self.bodyTextView.frame;
    frame.size.height = self.bodyTextView.contentSize.height;
    self.bodyTextView.frame = frame;
	
	
	
	if ([self.messageType isEqualToString:@"offer"])
	{
		[self setupAttachment];
    }
    else if ([_messageType isEqualToString:@"gift"])
	{
        
    }
	
	if(self.reply != [NSNull null])
	{
		[self setupReply];
	}
    
    //[self.scrollView sizeToFit];
    //[self.scrollView flashScrollIndicators];
	self.scrollView.contentSize = CGSizeMake(320, 1200); //TODO: calculate height properly.
}

- (void)setupReply
{
    [[NSBundle mainBundle] loadNibNamed:@"MessageReply" owner:self options:nil];
    
    self.replyDateLabel.text = [self formattedDateString:self.reply.createdAt];
	self.replySenderLabel.text = [self.reply objectForKey:@"sender_name"];
	self.replyBodyTextView.text = [self.reply objectForKey:@"body"];
	
    CGRect msgFrame = self.bodyTextView.frame;
    CGRect replyViewFrame = self.replyView.frame;
    CGRect replyTextViewFrame = self.replyBodyTextView.frame;
    
    replyViewFrame.origin.y = msgFrame.origin.y + msgFrame.size.height + 20;
    replyTextViewFrame.size.height = self.replyBodyTextView.contentSize.height;
    self.replyView.frame = replyViewFrame;
    self.replyBodyTextView.frame = replyTextViewFrame;
	self.replyView.hidden = FALSE;
    
    [self.scrollView addSubview:self.replyView];
    
}

- (void)setupAttachment
{
	[[NSBundle mainBundle] loadNibNamed:@"MessageAttachment" owner:self options:nil];
	
	CGRect msgFrame = self.bodyTextView.frame;
    CGRect giftViewFrame = self.giftView.frame;
    
    giftViewFrame.origin.y = msgFrame.origin.y + msgFrame.size.height + 15;
    self.giftView.frame = giftViewFrame;
	[self.giftView.layer setCornerRadius:14];
	[self.giftView setClipsToBounds:YES];
	[self.giftButton.layer setCornerRadius:5];
	[self.giftButton setClipsToBounds:YES];
	
	self.giftTitle.text = [NSString stringWithFormat:@"Offer: %@",[self.message objectForKey:@"offer_title"]];
	
	[self.scrollView addSubview:self.giftView];
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
    
    if (timeLeft <= 0) {
        self.giftTimerLabel.text = @"Expired";
        self.timer = nil;
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
	
	if(days > 0) {
		return [NSString stringWithFormat:@"%i days, %.2d:%.2d:%.2d", days, hours, minutes, seconds];
	} else {
		return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
	}
}

- (IBAction)giftButtonAction:(id)sender
{	
	if( [[self.messageStatus objectForKey:@"redeem_available"] isEqualToString:@"yes"] )
	{
		self.giftButton.enabled = NO;
		
		NSString *storeId = [[self.sharedData getStore:[self.message objectForKey:@"store_id"]] objectId];
		NSString *patronStoreId = [[self.sharedData getPatronStore:storeId] objectId];
		NSString *rewardTitle = [self.message objectForKey:@"offer_title"];
		NSString *customerName = [NSString stringWithFormat:@"%@ %@", [self.patron objectForKey:@"first_name"],
								  [self.patron objectForKey:@"last_name"]];
	
		NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
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
				 [self.messageStatus setObject:@"pending" forKey:@"redeem_available"];
				 
				 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Waiting for confirmation"
															  andMessage:@"Please wait for this offer to be validated"];
				 [alert addButtonWithTitle:@"OK"
									  type:SIAlertViewButtonTypeDefault
								   handler:^(SIAlertView *alertView) {}];
				 [alert show];
			 }
			 else
			 {
				 NSLog(@"request_redeem error: %@", error);
			 }
		 }];
		
	}
	else if( [[self.messageStatus objectForKey:@"redeem_available"] isEqualToString:@"pending"] )
	{
		SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Offer pending"
													 andMessage:@"You can only request this offer once"];
		[alert addButtonWithTitle:@"OK"
							 type:SIAlertViewButtonTypeDefault
						  handler:^(SIAlertView *alertView) {}];
		[alert show];
	}
	else
	{
		SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Offer redeemed"
													 andMessage:@"You have already redeemed this reward"];
		[alert addButtonWithTitle:@"OK"
							 type:SIAlertViewButtonTypeDefault
						  handler:^(SIAlertView *alertView) {}];
		[alert show];
	}
}

/*
- (IBAction)replyButtonAction:(id)sender
{

}
*/

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

- (void)showDialog:(NSString*)title withMessage:(NSString*)message
{
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title
                                                 andMessage:message];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

@end
