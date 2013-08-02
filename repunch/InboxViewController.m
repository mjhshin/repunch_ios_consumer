//
//  InboxViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "MessageAutoLayoutViewController.h"
#import "MessageCell.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#import <Parse/Parse.h>

@implementation InboxViewController
{
    NSMutableArray *messagesStatuses;
    PFObject *patronObject;
    UITableView *messageTable;
    UIActivityIndicatorView *spinner;
    UIView *greyedOutView;
}

-(void)setup
{
    PFRelation *messageStatus = [patronObject relationforKey:@"ReceivedMessages"];
    PFQuery *messageStatusQuery = [messageStatus query];
    [messageStatusQuery includeKey:@"Message"];
    [messageStatusQuery includeKey:@"Message.Reply"];

    [messageStatusQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedMessageStatuses, NSError *error) {
        
        //the array has to be mutable in order to later delete messages
        messagesStatuses = [fetchedMessageStatuses mutableCopy];
        
        //is sorted by updatedAt as opposed to createdAt, then will sort by reply date value (if there is a reply)
        messagesStatuses = [[messagesStatuses sortedArrayUsingDescriptors:[NSArray arrayWithObject: [NSSortDescriptor sortDescriptorWithKey:@"Message.updatedAt" ascending:NO]]] mutableCopy];
        
        //s.t. table is only as tall as there are cells
        [messageTable setContentSize:CGSizeMake(320, 78*messagesStatuses.count)];
        [messageTable reloadData];
        [[self view] addSubview:messageTable];
        
        [spinner stopAnimating];
        [greyedOutView removeFromSuperview];

    }];

}

- (void)viewDidLoad
{

    messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, 450) style:UITableViewStylePlain];
    [messageTable setFrame:CGRectMake(0, 50, 320, self.view.frame.size.height - 50)];

    [messageTable setDataSource:self];
    [messageTable setDelegate:self];
        
    //patronObject = [(AppDelegate *)[[UIApplication sharedApplication] delegate] patron];
    
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    /*
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 260);
    spinner.color = [UIColor blackColor];
    [[self view] addSubview:spinner];
    [spinner startAnimating];
    greyedOutView = [[UIView alloc]initWithFrame:CGRectMake(0, 47, 320, self.view.frame.size.height - 47)];
    [greyedOutView setBackgroundColor:[UIColor colorWithRed:127/255 green:127/255 blue:127/255 alpha:0.5]];
    [[self view] addSubview:greyedOutView];
    [[self view] bringSubviewToFront:greyedOutView];
    

    [self setup];
     */
}


-(void)viewDidDisappear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [messagesStatuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [[cell offerPic] setHidden:TRUE];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageCell" owner:self options:nil]objectAtIndex:0];
    }

    id currentCellMessageStatus = [messagesStatuses objectAtIndex:indexPath.row];
    id currentCellMessage = [currentCellMessageStatus objectForKey:@"Message"];
    id currentCellMessageReply = [currentCellMessage objectForKey:@"Reply"];
    
    if ([NSNull null] == currentCellMessageReply || currentCellMessageReply == NULL) {
        cell.senderName.text = [currentCellMessage valueForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [currentCellMessage valueForKey:@"subject"], [currentCellMessage valueForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:[currentCellMessage valueForKey:@"createdAt"]];
    }
    else {
        cell.senderName.text = [currentCellMessageReply valueForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"RE: %@ - %@", [currentCellMessage valueForKey:@"subject"], [currentCellMessageReply valueForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:[currentCellMessageReply valueForKey:@"createdAt"]];
    }

    
    if ([[currentCellMessage valueForKey:@"message_type"] isEqualToString:@"offer"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"ico_message_coupon"]];
    }
    if ([[currentCellMessage valueForKey:@"message_type"] isEqualToString:@"feedback"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_reply"]];
    }
    
    if ([[currentCellMessage valueForKey:@"message_type"] isEqualToString:@"gift"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_gift"]];
    }
    
    if ([[currentCellMessageStatus objectForKey:@"is_read"] boolValue]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(float)192/256 green:(float)192/256 blue:(float)192/256 alpha:(float)65/256]; //ARGB = 0x40C0C0C0
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    return cell;
     
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id currentCellMessageStatus = [messagesStatuses objectAtIndex:indexPath.row];
    id currentCellMessage = [currentCellMessageStatus objectForKey:@"Message"];
    
    MessageAutoLayoutViewController *messageVC = [[MessageAutoLayoutViewController alloc] init];
    messageVC.modalDelegate = self;
    messageVC.message = currentCellMessage;
    //messageVC.messageStatus currentCellMessage [savedMessageStatuses objectAtIndex:indexPath.row];
    messageVC.messageStatus = currentCellMessageStatus;
    messageVC.messageType = [currentCellMessage valueForKey:@"message_type"];
    messageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    messageVC.customerName = [NSString stringWithFormat:@"%@ %@", [localUser first_name], [localUser last_name]];
    messageVC.patronId = [localUser patronId];

    if ([[currentCellMessage objectForKey:@"is_read"] boolValue] == FALSE) {
        [currentCellMessageStatus setValue:[NSNumber numberWithBool:TRUE] forKey:@"is_read"];
        [messageTable reloadData];
    }
    [currentCellMessageStatus saveInBackground];
    
    [self presentViewController:messageVC animated:YES completion:NULL];
     
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
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
        NSTimeZone *thisTimeZone = [NSTimeZone localTimeZone];
        [formatter setDateFormat:@"hh:mm a"];
        [formatter setLocale:locale];
        [formatter setTimeZone:thisTimeZone];
        
        dateString = [formatter stringFromDate:dateCreated];
        
    } else {
        [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MM/dd" options:0 locale:locale]];
        [formatter setLocale:locale];
        dateString = [formatter stringFromDate:dateCreated];
    }

    return dateString;
}


#pragma mark - Modal View Delegate

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didDismissPresentedViewControllerWithCompletion{
    [self dismissViewControllerAnimated:YES completion:^{
        [messagesStatuses removeAllObjects];
        [self setup];
    }];
    
}

- (void)didDismissPresentedViewControllerWithCompletionCode:(NSString *)dismissString {
    if ([dismissString isEqualToString:@"deletedMessage"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [messagesStatuses removeAllObjects];
            [self setup];
        }];

    }
    
    if ([dismissString isEqualToString:@"logout"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate logout];
        }];

    }
}
- (IBAction)openSettings:(id)sender {
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    //settingsVC.userName = [localUser fullName];
    [self presentViewController:settingsVC animated:YES completion:NULL];

}

- (IBAction)openSearch:(id)sender {
    
    SearchViewController *placesSearchVC = [[SearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    [self presentViewController:placesSearchVC animated:YES completion:NULL];

}

- (IBAction)showPunchCode:(id)sender {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code" andMessage:[NSString stringWithFormat:@"Your punch code is %@", [localUser punch_code]]];
    [alert addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        //nothing happens
    }];
    [alert show];

}

- (IBAction)refreshPage:(id)sender {
    spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 260);
    spinner.color = [UIColor blackColor];
    [[self view] addSubview:spinner];
    [spinner startAnimating];
    greyedOutView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height - 50)];
    [greyedOutView setBackgroundColor:[UIColor colorWithRed:127/255 green:127/255 blue:127/255 alpha:0.5]];
    [[self view] addSubview:greyedOutView];
    [[self view] bringSubviewToFront:greyedOutView];
    
    [self setup];

}
@end
