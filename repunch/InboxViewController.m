//
//  InboxViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxViewController.h"

@implementation InboxViewController
{
	NSInteger alertBadgeCount;
	BOOL loadInProgress;
	int paginateCount;
	BOOL paginateReachEnd;
	UIActivityIndicatorView *spinner;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(addMessageFromPush:)
												 name:@"Message"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadInbox:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
    
    self.sharedData = [DataManager getSharedInstance];
    self.patron = [self.sharedData patron];
	self.messagesArray = [[NSMutableArray alloc] init];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	self.tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc]init];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(loadInbox:)
									  forControlEvents:UIControlEventValueChanged];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	int toolBarHeight = self.toolbar.frame.size.height;
	int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	int tableViewHeight = screenHeight - toolBarHeight;
	
	self.messageTableView = [[UITableView alloc]
						initWithFrame:CGRectMake(0, toolBarHeight, screenWidth, tableViewHeight - tabBarHeight)
								style:UITableViewStylePlain];
	
    [self.messageTableView setDataSource:self];
    [self.messageTableView setDelegate:self];
	[self.view addSubview:self.messageTableView];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.messageTableView setTableFooterView:footer];
	
	self.tableViewController.tableView = self.messageTableView;
	
	CGFloat xCenter = screenWidth/2;
	CGFloat yCenter = screenHeight/2;
	CGFloat xOffset = self.activityIndicatorView.frame.size.width/2;
	CGFloat yOffset = self.activityIndicatorView.frame.size.height/2;
	CGRect frame = self.activityIndicatorView.frame;
	frame.origin = CGPointMake(xCenter - xOffset, yCenter - yOffset);
	self.activityIndicatorView.frame = frame;
	
	CGFloat xOffset2 = self.emptyInboxLabel.frame.size.width/2;
	CGFloat yOffset2 = self.emptyInboxLabel.frame.size.height/2;
	CGRect frame2 = self.emptyInboxLabel.frame;
	frame2.origin = CGPointMake(xCenter - xOffset2, yCenter - yOffset2);
	self.emptyInboxLabel.frame = frame2;
	
	alertBadgeCount = 0;
	paginateCount = 0;
	loadInProgress = NO;
	paginateReachEnd = NO;
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	
    [self loadInbox:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:YES];
	[UIApplication sharedApplication].applicationIconBadgeNumber = alertBadgeCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadInbox:(BOOL)paginate
{
	loadInProgress = YES;
	
    PFRelation *messagesRelation = [self.patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
    [messageQuery includeKey:@"Message.Reply"];
	[messageQuery orderByDescending:@"createdAt"];
	messageQuery.limit = 20;
	
	if(paginate == YES)
	{
		++paginateCount;
		messageQuery.skip = 20*paginateCount;
		
		[self setFooter:YES];
	}
	else
	{
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
        //self.messageTableView.hidden = YES;
		self.emptyInboxLabel.hidden = YES;
	}
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
	{
		if(paginate == YES)
		{
			[self setFooter:NO];
		}
		else
		{
			[self.activityIndicatorView setHidden:YES];
			[self.activityIndicator stopAnimating];
			[self.tableViewController.refreshControl endRefreshing];
		}
		
        if(!error)
		{
            if (paginate != YES)
            {
                [self.messagesArray removeAllObjects];
                alertBadgeCount = 0;
                paginateReachEnd = NO;
            }

			for(PFObject *messageStatus in results)
			{
				[self.sharedData addMessage:messageStatus];
				[self.messagesArray addObject:messageStatus];
				
				if( ![[messageStatus objectForKey:@"is_read"] boolValue] ) {
					++alertBadgeCount;
				}
			}

			[self refreshTableView];
			
			if(paginate == YES && results.count == 0) {
				paginateReachEnd = YES;
			}
			loadInProgress = NO;
        }
		else
		{
            [RepunchUtils showDefaultErrorMessage];
            //self.messageTableView.hidden = NO;
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
   return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[InboxTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [InboxTableViewCell cell];
    }
    
    PFObject *messageStatus = [self.messagesArray objectAtIndex:indexPath.row];
    PFObject *message = [messageStatus objectForKey:@"Message"];
    PFObject *reply = [message objectForKey:@"Reply"];
    
    if (reply != (id)[NSNull null] && reply != nil) {
        cell.senderName.text = [reply objectForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"RE: %@ - %@",
										[message objectForKey:@"subject"], [reply objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:reply.createdAt];
		
    } else {
		cell.senderName.text = [message objectForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [message objectForKey:@"subject"], [message objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:message.createdAt];
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
        cell.contentView.backgroundColor = [UIColor colorWithRed:(float)192/256 //ARGB = 0x40C0C0C0
														   green:(float)192/256
															blue:(float)192/256
														   alpha:(float)65/256];
		cell.senderName.font = [UIFont fontWithName:@"Avenir" size:17];
		cell.dateSent.textColor = [UIColor darkGrayColor];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
		cell.senderName.font = [UIFont fontWithName:@"Avenir-Heavy" size:17];
		cell.dateSent.textColor = [UIColor colorWithRed:(240/255.0) green:(140/255.0) blue:(19/255.0) alpha:1.0];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    IncomingMessageViewController *messageVC = [[IncomingMessageViewController alloc] init];
	PFObject *messageStatus = [self.messagesArray objectAtIndex:indexPath.row];
    messageVC.messageStatusId = [messageStatus objectId];
	messageVC.delegate = self;
    [self presentViewController:messageVC animated:YES completion:NULL];
	 
	if( [[messageStatus objectForKey:@"is_read"] boolValue] == NO )
	{
		--alertBadgeCount;
		[self updateBadgeCount];
		
		[messageStatus setObject:[NSNumber numberWithBool:YES] forKey:@"is_read"]; //does this change is_read in shareddata?
		[messageStatus saveInBackground];
	
		[self.messageTableView beginUpdates];
		[self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		[self.messageTableView endUpdates];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollLocation = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    float scrollHeight = scrollView.contentSize.height;

    if(self.messagesArray.count >= 20 && scrollLocation >= scrollHeight + 5 && !loadInProgress && !paginateReachEnd)
	{
		[self loadInbox:YES];
    }
}

- (void)setFooter:(BOOL)paginateInProgress
{
	UIView *footer = self.messageTableView.tableFooterView;
	CGRect footerFrame = footer.frame;
	footerFrame.size.height = paginateInProgress ? 50 : 1;
	footer.frame = footerFrame;
	self.messageTableView.tableFooterView = footer;
	
	if(paginateInProgress)
	{
		spinner.frame = self.messageTableView.tableFooterView.bounds;
		[self.messageTableView.tableFooterView addSubview:spinner];
		[spinner startAnimating];
	}
	else
	{
		[spinner removeFromSuperview];
		[spinner stopAnimating];
	}
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

- (void)addMessageFromPush:(NSNotification *)notification
{
	NSString *msgStatusId = [[notification userInfo] objectForKey:@"message_status_id"];
	
	for(PFObject* msg in self.messagesArray) //if this is a reply, replace the original message
	{
		if( [msg.objectId isEqualToString:msgStatusId] )
		{
			if( ![[msg objectForKey:@"is_read"] boolValue] ) { //avoid incrementing badge count if it was already unread
				--alertBadgeCount;
			}
			[self.messagesArray removeObject:msg];
			break;
		}
	}
	
	[self.messagesArray insertObject:[self.sharedData getMessage:msgStatusId] atIndex:0];
	[self refreshTableView];
	
	++alertBadgeCount;
	[self updateBadgeCount];
}

- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(PFObject *)msgStatus
{
	//no need to update alert badge count because only read messages can be deleted
	NSLog(@"IncomingMessageVC->InboxVC IncomingMessageVCDelegate");
	if(msgStatus != nil) {
		[self.messagesArray removeObject:msgStatus];
	}
    [self refreshTableView];
}

- (void)refreshTableView
{
	[self updateBadgeCount];
	
	if(self.messagesArray.count > 0)
	{
		[self.messageTableView setHidden:NO];
		[self.emptyInboxLabel setHidden:YES];
	}
	else
	{
		[self.messageTableView setHidden:YES];
		[self.emptyInboxLabel setHidden:NO];
	}
	[self.messageTableView reloadData];
}

- (void)updateBadgeCount
{
	UITabBarItem *tab = [self.tabBarController.tabBar.items objectAtIndex:1];	
	tab.badgeValue = (alertBadgeCount == 0) ? nil : [NSString stringWithFormat:@"%i", alertBadgeCount];
	[UIApplication sharedApplication].applicationIconBadgeNumber = alertBadgeCount;
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	currentInstallation.badge = alertBadgeCount;
	[currentInstallation saveInBackground];
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
	NSString *punchCode = [self.patron objectForKey:@"punch_code"];
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Your Punch Code"
                                                 andMessage:punchCode];
	[alert setTitleFont:[UIFont fontWithName:@"Avenir" size:20]];
	[alert setMessageFont:[UIFont fontWithName:@"Avenir-Heavy" size:32]];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

@end
