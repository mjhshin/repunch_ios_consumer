//
//  MessageViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MessageViewController.h"
#import "PatronStore.h"
#import "SIAlertView.h"

@implementation MessageViewController{
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _messageName.text = [_message valueForKey:@"subject"];
    
    if ([_messageType isEqualToString:@"basic"]){
        _senderLabel.text = [_message valueForKey:@"sender_name"];
        _dateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _bodyLabel.text = [_message valueForKey:@"body"];
    }
    
    if ([_messageType isEqualToString:@"offer"]){
        _senderLabel.text = [_message valueForKey:@"sender_name"];
        _dateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _bodyLabel.text = [_message valueForKey:@"body"];
        
        [_offerTitleBtn setHidden:FALSE];
        [_offerTitleBtn setTitle:[_message valueForKey:@"offer_title"] forState:UIControlStateNormal];
        [_timeLeft setHidden:FALSE];
        [_timeLeftLabel setHidden:FALSE];
    }
    
    if ([_messageType isEqualToString:@"feedback"]){
        [_replierLabel setHidden:FALSE];
        [_replyBodyLabel setHidden:FALSE];
        
        //get previous message
        //TODO: add parent message
        
        _senderLabel.text = [[_message objectForKey:@"Reply"]valueForKey:@"sender_name"];
        _dateLabel.text = [self formattedDateString:[[_message objectForKey:@"Reply"] valueForKey:@"createdAt"]];
        _bodyLabel.text = [[_message objectForKey:@"Reply"] valueForKey:@"body"];
         
        
        _replierLabel.text = [_message valueForKey:@"sender_name"];
        _replyDateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _replyBodyLabel.text = [_message valueForKey:@"body"];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    
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
    // Dispose of any resources that can be recreated.
}

- (void)dismissPresentedViewController{
    [[self modalDelegate] didDismissPresentedViewController];
}

#pragma mark - Helper Methods

-(void)updateTimer{
    NSDate *offer = [_message valueForKey:@"date_offer_expiration"];
    NSDate *curDate = [NSDate date];
    
    NSTimeInterval timeLeft = [offer timeIntervalSinceDate:curDate];
    _timeLeft.text = [self stringFromInterval:timeLeft];
    
    if (timeLeft<=0){
        _timeLeft.text = @"Expired";
        _timeLeft = nil;
    }
    
}

-(NSString *)stringFromInterval:(NSTimeInterval)timeInterval
{
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}


-(NSString *)formattedDateString:(NSDate *)dateCreated{
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
        dateString = [formatter stringFromDate:dateCreated];
        
    } else {
        [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd" options:0 locale:locale]];
        [formatter setLocale:locale];
        dateString = [formatter stringFromDate:dateCreated];
    }
    
    return dateString;
}

- (IBAction)redeemOffer:(id)sender {
    PatronStore *patronStoreEntity= [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", _patronId, [_message valueForKey:@"store_id"]]];
    NSLog(@"%@", patronStoreEntity);

    NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"offer_title"], @"title", @"0", @"num_punches", _customerName, @"name", [_messageStatus objectId], @"message_status_id", nil];
    
    NSLog(@"dictionary is %@", functionArguments);
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redeem Offer" andMessage:[NSString stringWithFormat:@"Are you sure you want to redeem %@?", [_message valueForKey:@"offer_title"]]];
    
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              //Nothing Happens
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [PFCloud callFunctionInBackground:@"request_redeem"
                                                 withParameters:functionArguments
                                                          block:^(NSString *success, NSError *error) {
                                                              if (!error){
                                                                  SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You redeemed %@!", [_message valueForKey:@"offer_title"]]];
                                                                  [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                      //nothing
                                                                  }];

                                                                  [alertView show];
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
                              

                          }];
    [alertView show];
        

}

- (IBAction)closeMessage:(id)sender {
    [self dismissPresentedViewController];
}

- (IBAction)deleteMessage:(id)sender {
    [_message deleteInBackground];
    [[self modalDelegate] didDismissPresentedViewController];

}
@end
