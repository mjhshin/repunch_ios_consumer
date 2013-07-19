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
#import "ComposeViewController.h"

@implementation MessageViewController{
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _scrollView.scrollEnabled = NO;
    
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
                
        _senderLabel.text = [[_message objectForKey:@"Reply"]valueForKey:@"sender_name"];
        _dateLabel.text = [self formattedDateString:[[_message objectForKey:@"Reply"] valueForKey:@"createdAt"]];
        _bodyLabel.text = [[_message objectForKey:@"Reply"] valueForKey:@"body"];
         
        
        _replierLabel.text = [_message valueForKey:@"sender_name"];
        _replyDateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _replyBodyLabel.text = [_message valueForKey:@"body"];
    }
    
    if ([_messageType isEqualToString:@"gift"]){
        _senderLabel.text = [_message valueForKey:@"sender_name"];
        _dateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _bodyLabel.text = [_message valueForKey:@"body"];
        
        [_offerTitleBtn setHidden:FALSE];
        [_replyButton setHidden:FALSE];
        [_offerTitleBtn setTitle:[_message valueForKey:@"gift_title"] forState:UIControlStateNormal];
        
        if ([_message valueForKey:@"Reply"] != nil) {
            _scrollView.frame = CGRectMake(0, 47, 320, self.view.frame.size.height);
            _scrollView.contentSize = CGSizeMake(320, [self bottomOfLowestContent:self.view]);
            _scrollView.scrollEnabled = YES;

            [_responseDivider setHidden:FALSE];
            [_giftResponder setHidden:FALSE];
            [_giftResponseBody setHidden:FALSE];
            [_giftResponseDate setHidden:FALSE];
            
            _giftResponder.text = [[_message objectForKey:@"Reply"]valueForKey:@"sender_name"];
            _giftResponseDate.text = [self formattedDateString:[[_message objectForKey:@"Reply"] valueForKey:@"createdAt"]];
            _giftResponseBody.text = [[_message objectForKey:@"Reply"] valueForKey:@"body"];

        }

    }

}

#pragma mark - Self Helper Methods
- (CGFloat) bottomOfLowestContent:(UIView*) view
{
    CGFloat lowestPoint = 0.0;
    
    BOOL restoreHorizontal = NO;
    BOOL restoreVertical = NO;
    
    if ([view respondsToSelector:@selector(setShowsHorizontalScrollIndicator:)] && [view respondsToSelector:@selector(setShowsVerticalScrollIndicator:)])
    {
        if ([(UIScrollView*)view showsHorizontalScrollIndicator])
        {
            restoreHorizontal = YES;
            [(UIScrollView*)view setShowsHorizontalScrollIndicator:NO];
        }
        if ([(UIScrollView*)view showsVerticalScrollIndicator])
        {
            restoreVertical = YES;
            [(UIScrollView*)view setShowsVerticalScrollIndicator:NO];
        }
    }
    for (UIView *subView in view.subviews)
    {
        if (!subView.hidden)
        {
            CGFloat maxY = CGRectGetMaxY(subView.frame);
            if (maxY > lowestPoint)
            {
                lowestPoint = maxY;
            }
        }
    }
    if ([view respondsToSelector:@selector(setShowsHorizontalScrollIndicator:)] && [view respondsToSelector:@selector(setShowsVerticalScrollIndicator:)])
    {
        if (restoreHorizontal)
        {
            [(UIScrollView*)view setShowsHorizontalScrollIndicator:YES];
        }
        if (restoreVertical)
        {
            [(UIScrollView*)view setShowsVerticalScrollIndicator:YES];
        }
    }
    
    return lowestPoint;
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
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
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

    
    if ([_messageType isEqualToString:@"offer"]){
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
                                                                      if ([success isEqualToString:@"validated"]){
                                                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed %@!", [_message valueForKey:@"offer_title"]]];
                                                                          [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                              //nothing
                                                                          }];
                                                                          
                                                                          [alertView show];

                                                                      }
                                                                      else{
                                                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"Your %@ is awaiting validation", [_message valueForKey:@"offer_title"]]];
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
                                  

                              }];
        [alertView show];
    }
    if ([_messageType isEqualToString:@"gift"]){
        //check patron store exists
        //if yes, redeem gift
        
        NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"gift_title"], @"title", @"0", @"num_punches", _customerName, @"name", [_messageStatus objectId], @"message_status_id", nil];
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redeem Gift" andMessage:[NSString stringWithFormat:@"Are you sure you want to redeem %@?", [_message valueForKey:@"gift_title"]]];
        
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
                              }];
        [alertView show];


        
        
        //else, add patron store and then redeem gift
        if (!patronStoreEntity){
            NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:_patronId, @"patron_id", [_message valueForKey:@"store_id"], @"store_id", nil];

            [PFCloud callFunctionInBackground: @"add_patronstore"
                               withParameters:functionArguments block:^(PFObject *patronStore, NSError *error) {
                                   if (!error){
                                       NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"gift_title"], @"title", @"0", @"num_punches", _customerName, @"name", [_messageStatus objectId], @"message_status_id", nil];
                                       
                                       SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redeem Gift" andMessage:[NSString stringWithFormat:@"Are you sure you want to redeem %@?", [_message valueForKey:@"gift_title"]]];
                                       
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
                                                                                                     if ([success isEqualToString:@"validated"]){
                                                                                                         SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You've already redeemed %@!", [_message valueForKey:@"gift_title"]]];
                                                                                                         [alertView addButtonWithTitle:@"Okay." type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                                                                                             //nothing
                                                                                                         }];
                                                                                                         
                                                                                                         [alertView show];
                                                                                                         
                                                                                                     }
                                                                                                     else{
                                                                                                         SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Redemption" andMessage:[NSString stringWithFormat:@"You redeemed %@!", [_message valueForKey:@"gift_title"]]];
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

                                                             }];
                                       [alertView show];



                                       
                                   }
                                   else {
                                       
                                       SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
                                       [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                       }];
                                       
                                       NSLog(@"%@", error);
                                   }
                               }];

            
        }
        
    }
    

}

- (IBAction)closeMessage:(id)sender {
    [self dismissPresentedViewController];
}

- (IBAction)deleteMessage:(id)sender {
    [_messageStatus deleteInBackground];
    [[self modalDelegate] didDismissPresentedViewControllerWithCompletion];

}

- (IBAction)sendReply:(id)sender {
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.modalDelegate = self;
    composeVC.messageType = @"GiftReply";
    composeVC.sendParameters = [[NSDictionary alloc] initWithObjectsAndKeys:[_message objectId], @"message_id", nil];
    
    [self presentViewController:composeVC animated:YES completion:NULL];

}

-(void)didDismissPresentedViewController {
    [self dismissPresentedViewController];
    
}
@end
