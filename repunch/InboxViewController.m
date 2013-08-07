//
//  InboxViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "IncomingMessageViewController.h"
#import "InboxTableViewCell.h"
#import "DataManager.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#import <Parse/Parse.h>

@implementation InboxViewController
{
    DataManager *sharedData;
    PFObject *patron;
    NSMutableArray *messagesArray;
    UITableView *messageTableView;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    sharedData = [DataManager getSharedInstance];
    patron = [sharedData patron];
	messagesArray = [[NSMutableArray alloc] init];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	int toolBarHeight = self.toolbar.frame.size.height;
	int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	int tableViewHeight = screenHeight - toolBarHeight;
	
	messageTableView = [[UITableView alloc]
						initWithFrame:CGRectMake(0, toolBarHeight, screenWidth, tableViewHeight - tabBarHeight)
								style:UITableViewStylePlain];
	
    [messageTableView setDataSource:self];
    [messageTableView setDelegate:self];
	[[self view] addSubview:messageTableView];
	
	CGFloat xCenter = screenWidth/2;
	CGFloat yCenter = screenHeight/2;
	CGFloat xOffset = self.activityIndicatorView.frame.size.width/2;
	CGFloat yOffset = self.activityIndicatorView.frame.size.height/2;
	CGRect frame = self.activityIndicatorView.frame;
	frame.origin = CGPointMake(xCenter - xOffset, yCenter - yOffset);
	self.activityIndicatorView.frame = frame;
	
    [self loadInbox];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setup)
                                                 name:@"receivedPush"
                                               object:nil];
}


-(void)viewDidDisappear:(BOOL)animated
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)loadInbox
{
	[self.activityIndicatorView setHidden:FALSE];
	[self.activityIndicator startAnimating];
	[messageTableView setHidden:TRUE];
	
    PFRelation *messagesRelation = [patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
    [messageQuery includeKey:@"Message"];
    [messageQuery includeKey:@"Message.Reply"];
	[messageQuery orderByDescending:@"createdAt"];
	[messageQuery setLimit:20];
	//TODO: paginate!
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
	{
		[self.activityIndicatorView setHidden:TRUE];
		[self.activityIndicator stopAnimating];
		
        if(!error)
		{
			if(results.count > 0)
			{
				for(PFObject *messageStatus in results) {
					[sharedData addMessage:messageStatus];
					[messagesArray addObject:messageStatus];
				}
				[messageTableView reloadData];
				[messageTableView setHidden:FALSE];
			}
			else
			{
				//TODO: show empty inbox label
			}
        } else {
            
        }
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[InboxTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [InboxTableViewCell cell];
    }

    PFObject *messageStatus = [messagesArray objectAtIndex:indexPath.row];
    PFObject *message = [messageStatus objectForKey:@"Message"];
    PFObject *reply = [message objectForKey:@"Reply"];
    
    if (reply != [NSNull null]) {
        cell.senderName.text = [reply valueForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"RE: %@ - %@", [message valueForKey:@"subject"], [reply valueForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:[reply valueForKey:@"createdAt"]];
		
    } else {
		cell.senderName.text = [message valueForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [message valueForKey:@"subject"], [message valueForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:[message valueForKey:@"createdAt"]];
    }
    
    if ([[message valueForKey:@"message_type"] isEqualToString:@"offer"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"ico_message_coupon"]];
		
    } else if ([[message valueForKey:@"message_type"] isEqualToString:@"feedback"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_reply"]];
		
    } else if ([[message valueForKey:@"message_type"] isEqualToString:@"gift"]){
        [[cell offerPic] setHidden:FALSE];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_gift"]];
    } else {
		[[cell offerPic] setHidden:TRUE];
	}
    
    if ([[messageStatus objectForKey:@"is_read"] boolValue]) {
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
    IncomingMessageViewController *messageVC = [[IncomingMessageViewController alloc] init];
	PFObject *messageStatus = [messagesArray objectAtIndex:indexPath.row];
    messageVC.messageStatusId = [messageStatus objectId];

	//TODO: set message as read here or in messageVC?
    //[messageStatus saveInBackground];
    
    [self presentViewController:messageVC animated:YES completion:NULL];     
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

#pragma mark - Helper Methods

- (NSString *)formattedDateString:(NSDate *)dateCreated
{
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

- (IBAction)openSettings:(id)sender
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self presentViewController:settingsVC animated:YES completion:NULL];
}

- (IBAction)openSearch:(id)sender
{
    SearchViewController *placesSearchVC = [[SearchViewController alloc]init];
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

- (IBAction)showPunchCode:(id)sender
{
	NSString *punchCode = [patron objectForKey:@"punch_code"];
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code"
												 andMessage:[NSString stringWithFormat:@"Your punch code is %@", punchCode]];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];
}

@end
