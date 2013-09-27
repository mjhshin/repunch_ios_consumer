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
	
	alertBadgeCount = 0;
	paginateCount = 0;
	loadInProgress = NO;
	paginateReachEnd = NO;
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	
	[self setupNavigationBar];
	[self setupTableView];
    [self loadInbox:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	
	self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewDidDisappear:YES];
	[UIApplication sharedApplication].applicationIconBadgeNumber = alertBadgeCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"nav_settings.png"]
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(openSettings:)];
	
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"nav_search.png"]
									 style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(openSearch:)];
	
	UIButton *punchCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
	[punchCodeButton setImage:[UIImage imageNamed:@"repunch-logo.png"] forState:UIControlStateNormal];
	[punchCodeButton addTarget:self action:@selector(showPunchCode:) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.leftBarButtonItem = settingsButton;
	self.navigationItem.rightBarButtonItem = searchButton;
	self.navigationItem.titleView = punchCodeButton;
}

- (void)setupTableView
{
	self.tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc]init];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(loadInbox:)
									  forControlEvents:UIControlEventValueChanged];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	int tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
	
	self.messageTableView = [[UITableView alloc]
							 initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - tabBarHeight - navBarHeight)
							 style:UITableViewStylePlain];
	
    [self.messageTableView setDataSource:self];
    [self.messageTableView setDelegate:self];
	[self.view addSubview:self.messageTableView];
	self.messageTableView.layer.zPosition = -1.0;
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.messageTableView setTableFooterView:footer];
	
	self.tableViewController.tableView = self.messageTableView;
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
		if(self.messagesArray.count == 0) {
			self.activityIndicatorView.hidden = NO;
			[self.activityIndicator startAnimating];
		}
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
                paginateReachEnd = NO;
				paginateCount = 0;
				[self fetchBadgeCount];
            }

			for(PFObject *messageStatus in results)
			{
				[self.sharedData addMessage:messageStatus];
				[self.messagesArray addObject:messageStatus];
			}

			[self refreshTableView];
			
			if(paginate == YES && results.count < 20) {
				paginateReachEnd = YES;
			}
			loadInProgress = NO;
        }
		else
		{
            [RepunchUtils showDefaultErrorMessage];
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
        cell.subjectLabel.text = [NSString stringWithFormat:@"RE: %@ - %@", [message objectForKey:@"subject"], [reply objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:reply.createdAt];
    }
	else {
		cell.senderName.text = [message objectForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [message objectForKey:@"subject"], [message objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:message.createdAt];
    }
    
    if ([[message valueForKey:@"message_type"] isEqualToString:@"offer"]){
        [[cell offerPic] setHidden:NO];
        [[cell offerPic] setImage:[UIImage imageNamed:@"ico_message_coupon"]];
		
    } else if ([[message valueForKey:@"message_type"] isEqualToString:@"feedback"]){
        [[cell offerPic] setHidden:NO];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_reply"]];
		
    } else if ([[message valueForKey:@"message_type"] isEqualToString:@"gift"]){
        [[cell offerPic] setHidden:NO];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_gift"]];
    } else {
		[[cell offerPic] setHidden:YES];
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
	self.tabBarController.tabBar.hidden = YES;
    IncomingMessageViewController *messageVC = [[IncomingMessageViewController alloc] init];
	PFObject *messageStatus = [self.messagesArray objectAtIndex:indexPath.row];
    messageVC.messageStatusId = [messageStatus objectId];
	messageVC.delegate = self;
    [self.navigationController pushViewController:messageVC animated:YES];
	 
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

    if(scrollLocation >= scrollHeight + 5 && !loadInProgress && !paginateReachEnd)
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
        
    }
	else {
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
	if(self.messagesArray.count > 0)
	{
		//[self.messageTableView setHidden:NO];
		[self.emptyInboxLabel setHidden:YES];
	}
	else
	{
		//[self.messageTableView setHidden:YES];
		[self.emptyInboxLabel setHidden:NO];
	}
	[self.messageTableView reloadData];
}

- (void)fetchBadgeCount
{
	PFRelation *messagesRelation = [self.patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
	[messageQuery whereKey:@"is_read" equalTo:[NSNumber numberWithBool:NO]];
	[messageQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error)
	{
		if (!error) {
			alertBadgeCount = count;
			[self updateBadgeCount];
		} else {
			// The request failed
		}
	}];
}

- (void)updateBadgeCount
{
	if(alertBadgeCount < 0) {
		alertBadgeCount = 0;
	}
	
	UITabBarItem *tab = [self.tabBarController.tabBar.items objectAtIndex:1];	
	tab.badgeValue = (alertBadgeCount == 0) ? nil : [NSString stringWithFormat:@"%i", alertBadgeCount];
	[UIApplication sharedApplication].applicationIconBadgeNumber = alertBadgeCount;
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	currentInstallation.badge = alertBadgeCount;
	[currentInstallation saveInBackground];
}

- (IBAction)openSettings:(id)sender
{
	self.tabBarController.tabBar.hidden = YES;
	
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}

- (IBAction)openSearch:(id)sender
{
	self.tabBarController.tabBar.hidden = YES;
	
    SearchViewController *searchVC = [[SearchViewController alloc] init];
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:searchVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
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
