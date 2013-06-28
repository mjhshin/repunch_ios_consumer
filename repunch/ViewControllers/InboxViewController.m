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

#import "GlobalToolbar.h"
#import "MessageCell.h"

#import "User.h"
#import "Message.h"

#import <Parse/Parse.h>

@implementation InboxViewController{
    NSArray *savedMessages;
    User *localUser;
    PFObject *patronObject;
    UITableView *messageTable;
}
-(void)setup{
    PFRelation *messages = [patronObject relationforKey:@"ReceivedMessages"];
    [[messages query] findObjectsInBackgroundWithBlock:^(NSArray *fetchedMessages, NSError *error) {
        savedMessages = fetchedMessages;
        [messageTable reloadData];
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GlobalToolbar *globalToolbar;
    globalToolbar = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [(GlobalToolbar *)globalToolbar setToolbarDelegate:self];
    [self.view addSubview:globalToolbar];


    messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 450) style:UITableViewStylePlain];
    [messageTable setDataSource:self];
    [messageTable setDelegate:self];
    [[self view] addSubview:messageTable];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];
    patronObject = [(AppDelegate *)[[UIApplication sharedApplication] delegate] patronObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
    

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
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageCell" owner:self options:nil]objectAtIndex:0];
    }
    id currentCellMessage = [savedMessages objectAtIndex:indexPath.row];
    cell.senderName.text = [currentCellMessage valueForKey:@"sender_name"];
    cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [currentCellMessage valueForKey:@"subject"], [currentCellMessage valueForKey:@"body"]];
    cell.dateSent.text = [self formattedDateString:[currentCellMessage valueForKey:@"createdAt"]];
    if ([[currentCellMessage valueForKey:@"message_type"] isEqualToString:@"offer"]){
        [[cell offerPic] setHidden:FALSE];
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

#pragma mark - Global Toolbar Delegate

- (void) openSearch
{
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

#pragma mark - Modal View Delegate

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
