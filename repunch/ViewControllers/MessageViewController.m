//
//  MessageViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/26/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "MessageViewController.h"

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
    
    _senderLabel.text = [_message valueForKey:@"sender_name"];
    _dateLabel.text = [self formattedDateString:[_message valueForKey:@"createdAt"]];
    
    _bodyLabel.text = [_message valueForKey:@"body"];

    _bodyLabel.numberOfLines = 100/19;




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

@end
