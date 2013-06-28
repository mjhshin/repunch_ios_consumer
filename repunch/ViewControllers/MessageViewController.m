//
//  MessageViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MessageViewController.h"
#import "PatronStore.h"

@implementation MessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //THIS IS A TOOLBAR
    //FROM HERE...
    UIToolbar *placeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(dismissPresentedViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closePlaceButton];
    
    UILabel *placeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)];
    [placeTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:[_message valueForKey:@"subject"]];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *deleteMessageImage = [UIImage imageNamed:@"ab_message_delete"];
    UIButton *deleteMessage= [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteMessage setImage:deleteMessageImage forState:UIControlStateNormal];
    [deleteMessage setFrame:CGRectMake(0, 0, deleteMessageImage.size.width, deleteMessageImage.size.height)];
    [deleteMessage addTarget:self action:@selector(deleteMessage) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *deleteMessageTitle = [[UIBarButtonItem alloc] initWithCustomView:deleteMessage];

    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, deleteMessageTitle, nil]];
    [self.view addSubview:placeToolbar];
    //... TO HERE.  END TOOLBAR.
    
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
        /*
        _senderLabel.text = 
        _dateLabel.text = 
        _bodyLabel.text =
         */

        _replierLabel.text = [_message valueForKey:@"sender_name"];
        _replyDateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
        _replyBodyLabel.text = [_message valueForKey:@"body"];
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

    NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_message valueForKey:@"store_id"], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [_message valueForKey:@"offer_title"], @"title", @"0", @"num_punches", _customerName, @"name", nil];
    
    NSLog(@"dictionary is %@", functionArguments);
    
    
    [PFCloud callFunctionInBackground:@"request_redeem"
                       withParameters:functionArguments
                                block:^(NSString *success, NSError *error) {
                                    if (!error){
                                        NSLog(@"function call is :%@", success);
                                    }
                                    else
                                        NSLog(@"error occurred: %@", error);
                                }];
     
     

}

-(void)deleteMessage{
    [_message deleteInBackground];
    [[self modalDelegate] didDismissPresentedViewController];
}
@end
