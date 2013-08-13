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
	self.messageStatus = [self.sharedData getMessage:_messageStatusId];
	self.message = [self.messageStatus objectForKey:@"Message"];
	self.reply = [self.message objectForKey:@"Reply"];
	self.messageType = [self.message objectForKey:@"message_type"];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	[self.messageTitle setText:[self.message objectForKey:@"subject"]];
	
	[self setupMessage];
}

- (void)viewWillAppear:(BOOL)animated
{
	/*
    if([_messageType isEqualToString:@"offer"]){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(updateTimer)
                                               userInfo:nil
                                                repeats:YES];
        
        [self updateTimer];
    }
	 */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupMessage
{
	self.dateLabel.text = [self formattedDateString:self.message.createdAt];
	self.senderLabel.text = [self.message objectForKey:@"sender_name"];
	self.bodyTextView.text = [self.message objectForKey:@"body"];
	
	if(self.reply != [NSNull null])
	{
		//[self setupReply];
	}
	
	if ([self.messageType isEqualToString:@"basic"])
	{
		
    }
    else if ([self.messageType isEqualToString:@"offer"])
	{
		
    }
    else if ([self.messageType isEqualToString:@"feedback"])
	{
		
    }
    else if ([_messageType isEqualToString:@"gift"])
	{
        
    }
}

- (void)setupReply
{
	[[NSBundle mainBundle] loadNibNamed:@"MessageReply" owner:self options:nil];
	
	CGRect frame = self.replyView.frame;
	frame.origin = CGPointMake(0, self.messageView.frame.size.height);
	self.replyView.frame = frame;
	self.replyView.hidden = FALSE;
	[self.scrollView addSubview:self.replyView];
	
	self.replyDateLabel.text = [self formattedDateString:self.reply.createdAt];
	self.replySenderLabel.text = [self.reply objectForKey:@"sender_name"];
	self.replyBodyTextView.text = [self.reply objectForKey:@"body"];
}

- (void)setupAttachment
{
	[[NSBundle mainBundle] loadNibNamed:@"MessageAttachment" owner:self options:nil];
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
    self.giftTimerLabel.text = [self stringFromInterval:timeLeft];
    
    if (timeLeft <= 0) {
        self.giftTimerLabel.text = @"Expired";
        self.timer = nil;
    }
}

-(NSString *)stringFromInterval:(NSTimeInterval)timeInterval
{
    
    int seconds_per_minute = 60;
    int minutes_per_hour = 60;
    int seconds_per_hour = seconds_per_minute * minutes_per_hour;
    int hours_per_day = 24;
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / seconds_per_hour) % hours_per_day, (ti / seconds_per_minute) % minutes_per_hour, ti % seconds_per_minute];
    
}

#pragma mark - Toolbar Methods

/*
- (IBAction)replyToMessageActn:(id)sender
{
    ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	//composeVC.storeId =
    composeVC.messageType = @"gift_reply"; //TODO: make this an enum
    
    [self presentViewController:composeVC animated:YES completion:NULL];
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

/*
- (IBAction)redeemOfferActn:(id)sender {
    
    if ([_messageType isEqualToString:@"offer"]){
        //NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"offer_title"], @"title", @"0", @"num_punches", _customerName, @"name", [_messageStatus objectId], @"message_status_id", nil];
        
        NSLog(@"dictionary is %@", functionArguments);
        
          if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"pending"]){
              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"This reward is pending."]];
              [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
              
              [alertView show];
          }
          
          else if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"no"]) {
              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed this reward."]];
              [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
              
              [alertView show];
          }
          

          else if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"yes"]) {
              NSDate *offerExpiration = [_message valueForKey:@"date_offer_expiration"];
              if ([offerExpiration timeIntervalSinceNow] <= 0) {
                  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sorry" andMessage:[NSString stringWithFormat:@"This offer has expired"]];
                  [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
                  
                  [alertView show];

              }
              else {
                  [PFCloud callFunctionInBackground:@"request_redeem"
                                 withParameters:functionArguments
                                          block:^(NSString *success, NSError *error) {
                                              if (!error){

                                                  
                                                  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"Your %@ is awaiting validation", [_message valueForKey:@"offer_title"]]];
                                                  [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
                                                  [alertView show];
                                                  
                                                  NSLog(@"function call is :%@", success);
                                              }
                                              
                                              else{
                                                  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sorry" andMessage:[NSString stringWithFormat:@"Looks like something went wrong."]];
                                                  [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
                                                  
                                                  [alertView show];
                                                  
                                                  NSLog(@"error occurred: %@", error);
                                              }
                                          }];
              
                  }
          }
        
                                  
    }
    if ([_messageType isEqualToString:@"gift"]){
        //check patron store exists
        //if yes, redeem gift
        
        NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"gift_title"], @"title", @"0", @"num_punches", _customerName, @"name", [_messageStatus objectId], @"message_status_id", nil];
        
        
        if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"pending"]){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"This reward is pending."]];
            [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
            
            [alertView show];
        }
        
        else if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"no"]) {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed this reward."]];
            [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:nil];
            
            [alertView show];
        }
        
        else if ([[_messageStatus valueForKey:@"redeem_available"] isEqualToString:@"yes"]) {
            
            
            //if user doesn't have patron store, add it
            if (!patronStoreEntity){
                NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:_patronId, @"patron_id", [_message valueForKey:@"store_id"], @"store_id", nil];
                
                [PFCloud callFunctionInBackground: @"add_patronstore"
                                   withParameters:functionArguments block:^(PFObject *patronStore, NSError *error) {
                                       if (!error){
                                           [PFCloud callFunctionInBackground:@"request_redeem"
                                                              withParameters:functionArguments
                                                                       block:^(NSString *success, NSError *error) {
                                                                           if (!error){
                                                                               if ([success isEqualToString:@"validated"]){
                                                                                   SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed %@!", [_message valueForKey:@"gift_title"]]];
                                                                                   [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                                       //nothing
                                                                                   }];
                                                                                   
                                                                                   [alertView show];
                                                                                   
                                                                               }
                                                                               else{
                                                                                   SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"Your %@ is awaiting validation", [_message valueForKey:@"gift_title"]]];
                                                                                   [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                                       //nothing
                                                                                   }];
                                                                                   
                                                                                   [alertView show];
                                                                               }
                                                                               NSLog(@"function call is :%@", success);
                                                                           }
                                                                           else{
                                                                               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sorry" andMessage:[NSString stringWithFormat:@"Looks like something went wrong."]];
                                                                               [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                                   //nothing
                                                                               }];
                                                                               
                                                                               
                                                                               [alertView show];
                                                                               
                                                                               NSLog(@"error occurred: %@", error);
                                                                           }
                                                                       }];
                                           
                                       }
                                       else {
                                           
                                           SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
                                           [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                           }];
                                           
                                           NSLog(@"%@", error);
                                       }
                                   }];
            }

                //else just redeem gift
              [PFCloud callFunctionInBackground:@"request_redeem"
                                 withParameters:functionArguments
                                          block:^(NSString *success, NSError *error) {
                                              if (!error){
                                                  if ([success isEqualToString:@"validated"]){
                                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed %@!", [_message valueForKey:@"gift_title"]]];
                                                      [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                          //nothing
                                                      }];
                                                      
                                                      [alertView show];
                                                      
                                                  }
                                                  else{
                                                      SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"Your %@ is awaiting validation", [_message valueForKey:@"gift_title"]]];
                                                      [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                          //nothing
                                                      }];
                                                      
                                                      [alertView show];
                                                  }
                                                  NSLog(@"function call is :%@", success);
                                              }
                                              else{
                                                  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sorry" andMessage:[NSString stringWithFormat:@"Looks like something went wrong."]];
                                                  [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                      //nothing
                                                  }];
                                                  
                                                  
                                                  [alertView show];
                                                  
                                                  NSLog(@"error occurred: %@", error);
                                              }
                                          }];
        }
        
        
        
        
        
    }

    
}
 */

- (IBAction)giftButtonAction:(id)sender
{
	
}

- (void)showDialog:(NSString*)title withMessage:(NSString*)message
{
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title
                                                 andMessage:message];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];
}

@end
