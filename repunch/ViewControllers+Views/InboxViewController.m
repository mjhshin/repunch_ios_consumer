//
//  InboxViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "PlacesSearchViewController.h"
#import "MessageViewController.h"
#import "SettingsViewController.h"

#import "GlobalToolbar.h"
#import "MessageCell.h"
#import "SIAlertView.h"

#import "User.h"
#import "Message.h"

#import <Parse/Parse.h>

@implementation InboxViewController{
    NSMutableArray *savedMessages;
    NSArray *savedMessageStatuses;
    User *localUser;
    PFObject *patronObject;
    UITableView *messageTable;
    UIActivityIndicatorView *spinner;
    UIView *greyedOutView;
}
-(void)setup{
    PFRelation *messageStatus = [patronObject relationforKey:@"ReceivedMessages"];
    PFQuery *messageStatusQuery = [messageStatus query];
    [messageStatusQuery includeKey:@"Message"];
    [messageStatusQuery includeKey:@"Message.Reply"];
    [messageStatusQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedMessageStatuses, NSError *error) {
        savedMessageStatuses = fetchedMessageStatuses;
        savedMessages = [fetchedMessageStatuses valueForKey:@"Message"];
        savedMessages = [[savedMessages sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]] mutableCopy];
        
        [messageTable setFrame:CGRectMake(0, 46, 320, self.view.frame.size.height)];
        [messageTable setContentSize:CGSizeMake(320, 78*savedMessages.count)];

        [messageTable reloadData];
        [[self view] addSubview:messageTable];
        [spinner stopAnimating];
        [greyedOutView removeFromSuperview];

    }];

}

- (void)viewDidLoad
{

    messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 450) style:UITableViewStylePlain];
    [messageTable setDataSource:self];
    [messageTable setDelegate:self];
    //[[self view] addSubview:messageTable];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];
    patronObject = [(AppDelegate *)[[UIApplication sharedApplication] delegate] patronObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    
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
}


-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
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
   return [savedMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [[cell offerPic] setHidden:TRUE];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageCell" owner:self options:nil]objectAtIndex:0];
    }
    

    id currentCellMessage = [savedMessages objectAtIndex:indexPath.row];
    id currentCellMessageStatus = [savedMessageStatuses objectAtIndex:indexPath.row];

    cell.senderName.text = [currentCellMessage valueForKey:@"sender_name"];
    cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [currentCellMessage valueForKey:@"subject"], [currentCellMessage valueForKey:@"body"]];
    cell.dateSent.text = [self formattedDateString:[currentCellMessage valueForKey:@"createdAt"]];
    NSLog(@"date is %@", [currentCellMessage valueForKey:@"createdAt"]);
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
        cell.contentView.backgroundColor = [UIColor colorWithRed:(float)190/256 green:(float)190/256 blue:(float)190/256 alpha:1];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];

    }

    return cell;
     
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageViewController *messageVC = [[MessageViewController alloc] init];
    messageVC.modalDelegate = self;
    messageVC.message = [savedMessages objectAtIndex:indexPath.row];
    messageVC.customerName = [NSString stringWithFormat:@"%@ %@", [localUser first_name], [localUser last_name]];
    messageVC.patronId = [localUser patronId];
    messageVC.messageType = [[savedMessages objectAtIndex:indexPath.row] valueForKey:@"message_type"];
    messageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    messageVC.messageStatus = [savedMessageStatuses objectAtIndex:indexPath.row];
        
    [[savedMessageStatuses objectAtIndex:indexPath.row] setValue:[NSNumber numberWithBool:TRUE] forKey:@"is_read"];
    [[savedMessageStatuses objectAtIndex:indexPath.row] saveInBackground];
    
    [self presentViewController:messageVC animated:YES completion:NULL];
     
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
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
        [savedMessages removeAllObjects];
        [self setup];
    }];
    
}

- (IBAction)openSettings:(id)sender {
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingsVC.modalDelegate = self;
    settingsVC.userName = [localUser fullName];
    [self presentViewController:settingsVC animated:YES completion:NULL];

}

- (IBAction)openSearch:(id)sender {
    
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
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
@end
