//
//  IncomingMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "IncomingMessageViewController.h"
#import "ComposeMessageViewController.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#import "DataManager.h"

@implementation IncomingMessageViewController
{
	DataManager *sharedData;
	PFObject *patron;
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sharedData = [DataManager getSharedInstance];
	self.messageStatus = [sharedData getMessage:_messageStatusId];
	self.message = [_messageStatus objectForKey:@"Message"];
	self.messageType = [_message objectForKey:@"message_type"];
	_customerName = [_message objectForKey:@"customer_name"];
    
    [_messageHeader setText:[_message objectForKey:@"subject"]];
    [[_offerLbl titleLabel] setNumberOfLines:2];
    [[_offerLbl titleLabel] setTextAlignment:NSTextAlignmentCenter];

    if ([_messageType isEqualToString:@"basic"]){

        [_sentBodyLbl setText:[_message objectForKey:@"body"]];
        [_senderNameLbl setText:[_message valueForKey:@"sender_name"]];
        [_dateSentLbl setText:[self formattedDateString:[_message valueForKey:@"createdAt"]]];
    
        //use autolayout to hide response and offer view and adjust accordingly
        [self hideResponseAndAdjustConstraints];
        [self hideOfferAndAdjustConstraints];

    }
    
    if ([_messageType isEqualToString:@"offer"]){
        [_sentBodyLbl setText:[_message objectForKey:@"body"]];
        [_senderNameLbl setText:[_message valueForKey:@"sender_name"]];
        [_dateSentLbl setText:[self formattedDateString:[_message valueForKey:@"createdAt"]]];
        
        [_offerView setHidden:FALSE];
        [_offerLbl setTitle:[_message valueForKey:@"offer_title"] forState:UIControlStateNormal];
        
        //use autolayout to hide response view and adjust accordingly
        [self hideResponseAndAdjustConstraints];
        

    }
    
    if ([_messageType isEqualToString:@"feedback"]){
        
        [_responseView setHidden:FALSE];
        
        _replyNameLbl.text = [[_message objectForKey:@"Reply"]valueForKey:@"sender_name"];
        _dateRepliedLbl.text = [self formattedDateString:[[_message objectForKey:@"Reply"] valueForKey:@"createdAt"]];
        _repliedBodyLbl.text = [[_message objectForKey:@"Reply"] valueForKey:@"body"];
        
        
        _senderNameLbl.text = [_message valueForKey:@"sender_name"];
        _dateRepliedLbl.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _sentBodyLbl.text = [_message valueForKey:@"body"];
        
        //use autolayout to hide offer view and adjust accordingly
        [self hideOfferAndAdjustConstraints];
        [_constraintBtwnMessageAndResponse setConstant:4.0f];

    }
    
    if ([_messageType isEqualToString:@"gift"]){
        _senderNameLbl.text = [_message valueForKey:@"sender_name"];
        _dateSentLbl.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _sentBodyLbl.text = [_message valueForKey:@"body"];
        
        [_offerView setHidden:FALSE];
        [_offerCountdownLbl setHidden:TRUE];
        [_offerTimeLeftLbl setHidden:TRUE];
        
        [_replyToMessageLbl setHidden:FALSE];
        [_offerLbl setTitle:[_message valueForKey:@"gift_title"] forState:UIControlStateNormal];
        
        
        if ([_message valueForKey:@"Reply"] != nil) {
            
            [_responseView setHidden:FALSE];
            
            _replyNameLbl.text = [[_message objectForKey:@"Reply"]valueForKey:@"sender_name"];
            _dateRepliedLbl.text = [self formattedDateString:[[_message objectForKey:@"Reply"] valueForKey:@"createdAt"]];
            _repliedBodyLbl.text = [[_message objectForKey:@"Reply"] valueForKey:@"body"];
            
            [_offerLbl setUserInteractionEnabled:NO];
            [_replyToMessageLbl setHidden:TRUE];

            
            [_repliedBodyHeightLayout setConstant:_repliedBodyLbl.contentSize.height];
        }
        else {
            [self hideResponseAndAdjustConstraints];

        }
        
    }
    
    [_sentBodyHeightConstraint setConstant:_sentBodyLbl.contentSize.height];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
	
    if([_messageType isEqualToString:@"offer"]){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(updateTimer)
                                               userInfo:nil
                                                repeats:YES];
        
        [self updateTimer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Helper Methods
         
 -(NSString *)formattedDateString:(NSDate *)dateCreated {
     NSString *dateString = @"";
     
     NSCalendar *cal = [NSCalendar currentCalendar];
     NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
     NSDate *today = [cal dateFromComponents:components];
     components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dateCreated];
     NSDate *otherDate = [cal dateFromComponents:components];
     
     NSLocale *locale = [NSLocale currentLocale];
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     
     if([today isEqualToDate:otherDate]) {
         [formatter setDateFormat:@"hh:mm a"];
         [formatter setLocale:locale];
         [formatter setTimeZone:[NSTimeZone localTimeZone]];
         dateString = [formatter stringFromDate:dateCreated];
         
     } else {
         [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd" options:0 locale:locale]];
         [formatter setLocale:locale];
         dateString = [formatter stringFromDate:dateCreated];
     }
     
     return dateString;
 }

-(void)updateTimer {
    NSDate *offer = [_message valueForKey:@"date_offer_expiration"];
    NSDate *curDate = [NSDate date];
    
    NSTimeInterval timeLeft = [offer timeIntervalSinceDate:curDate];
    _offerCountdownLbl.text = [self stringFromInterval:timeLeft];
    
    if (timeLeft<=0){
        _offerCountdownLbl.text = @"Expired";
        timer = nil;
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

-(void)hideOfferAndAdjustConstraints {
    //[_offerViewHeightConstraint setConstant:0.0f];
    [_offerView removeFromSuperview];
}

-(void)hideResponseAndAdjustConstraints {
    //[_responseViewHeightConstraint setConstant:0.0f];
    [_responseView removeFromSuperview];
}

         
#pragma mark - Modal Delegate methods

-(void)didDismissPresentedViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Toolbar Methods

- (IBAction)replyToMessageActn:(id)sender {
    ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	//composeVC.storeId =
    composeVC.messageType = @"gift_reply"; //TODO: make this an enum
    
    [self presentViewController:composeVC animated:YES completion:NULL];
}

- (IBAction)deleteMessageActn:(id)sender {
    [_messageStatus deleteInBackground];
    //[[self modalDelegate] didDismissPresentedViewControllerWithCompletionCode:@"deletedMessage"];

}

- (IBAction)closeSettingActn:(id)sender {
    [self didDismissPresentedViewController];
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

@end
