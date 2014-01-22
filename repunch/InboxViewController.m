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
	UIActivityIndicatorView *paginateSpinner;
	UISegmentedControl *segmentedControl;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
	self.sharedData = [DataManager getSharedInstance];
    self.patron = [self.sharedData patron];
	self.messagesArray = [[NSMutableArray alloc] init];
	self.offersArray = [[NSMutableArray alloc] init];
	self.giftsArray = [[NSMutableArray alloc] init];
	
	alertBadgeCount = 0;
	paginateCount = 0;
	loadInProgress = NO;
	paginateReachEnd = NO;
	paginateSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	paginateSpinner.hidesWhenStopped = YES;
	
	[self registerForNotifications];
	[self setupNavigationBar];
	[self setupTableView];
    [self loadInbox:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{	
	[super viewDidDisappear:animated];
	[UIApplication sharedApplication].applicationIconBadgeNumber = alertBadgeCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(addMessageFromPush:)
												 name:@"Message"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshWhenBackgroundRefreshDisabled)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
	
	__weak typeof(self) weakSelf = self;
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	
	reach.reachableBlock = ^(Reachability*reach) {
		if(weakSelf.messagesArray.count == 0) {
			[weakSelf loadInbox:NO];
		}
		else {
			[weakSelf refreshTableView];
		}
	};
	[reach startNotifier];
}

- (void)setupNavigationBar
{
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"settings_icon.png"]
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(openSettings)];
	
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"search_icon.png"]
									 style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(openSearch)];
	
	NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Offers", @"Gifts", nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
	[segmentedControl addTarget:self
						 action:@selector(filterMessages)
			   forControlEvents:UIControlEventValueChanged];
	NSDictionary *attributes = [NSDictionary dictionaryWithObject:[RepunchUtils repunchFontWithSize:16 isBold:NO]
														   forKey:NSFontAttributeName];
	[segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
	segmentedControl.selectedSegmentIndex = 0;
	
	self.navigationItem.leftBarButtonItem = settingsButton;
	self.navigationItem.rightBarButtonItem = searchButton;
	self.navigationItem.titleView = segmentedControl;
}

- (void)setupTableView
{
	self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
	[self.tableViewController.refreshControl setTintColor:[RepunchUtils repunchOrangeColor]];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(loadInbox:)
									  forControlEvents:UIControlEventValueChanged];
	
    self.tableViewController.view.frame = self.view.bounds;
	self.tableViewController.view.layer.zPosition = -1;

    [self.tableViewController.tableView setDataSource:self];
    [self.tableViewController.tableView setDelegate:self];
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.tableViewController.tableView setTableFooterView:footer];
	
	 [self.view addSubview:self.tableViewController.tableView];
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)loadInbox:(BOOL)paginate
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[self.tableViewController.refreshControl endRefreshing];
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	loadInProgress = YES;
	
    PFRelation *messagesRelation = [self.patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
    [messageQuery includeKey:@"Message.Reply"];
	[messageQuery orderByDescending:@"createdAt"];
	messageQuery.limit = 20;
	
	if(paginate == YES) {
		++paginateCount;
		messageQuery.skip = 20*paginateCount;
		
		[self setFooter:YES];
	}
	else if(self.messagesArray.count == 0) {
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
		self.emptyInboxLabel.hidden = YES;
	}
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		if(paginate == YES) {
			[self setFooter:NO];
		}
		else {
			self.activityIndicatorView.hidden = YES;
			[self.activityIndicator stopAnimating];
			[self.tableViewController.refreshControl endRefreshing];
		}
		
        if(!error) {
            if (paginate != YES) {
                [self.messagesArray removeAllObjects];
				[self.offersArray removeAllObjects];
				[self.giftsArray removeAllObjects];
				
                paginateReachEnd = NO;
				paginateCount = 0;
				[self fetchBadgeCount];
            }

			for(PFObject *messageStatus in results) {
				[self.sharedData addMessage:messageStatus];
				[self addMessage:messageStatus fromPush:NO];
			}

			[self refreshTableView];
			
			if(paginate == YES && results.count < 20) {
				paginateReachEnd = YES;
			}
			loadInProgress = NO;
        }
		else {
            [RepunchUtils showConnectionErrorDialog];
        }
    }];
}

- (void)filterMessages
{
	[self refreshTableView];
}

- (void)refreshWhenBackgroundRefreshDisabled
{
	if([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable) {
		[self loadInbox:NO];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) { // All Messages
		return [self.messagesArray count];
	}
	else if(filter == 1) { // Offers
		return [self.offersArray count];
	}
	else { // Gifts
		return [self.giftsArray count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[InboxTableViewCell reuseIdentifier]];
	if (cell == nil) {
        cell = [InboxTableViewCell cell];
    }
	
	PFObject *messageStatus;
	
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) { // All Messages
		messageStatus = self.messagesArray[indexPath.row];
	}
	else if(filter == 1) { // Offers
		messageStatus = self.offersArray[indexPath.row];
	}
	else { // Gifts
		messageStatus = self.giftsArray[indexPath.row];
	}

    PFObject *message = [messageStatus objectForKey:@"Message"];
    PFObject *reply = [message objectForKey:@"Reply"];
    
    if ( !IS_NIL(reply) ) {
        cell.senderName.text = [reply objectForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"RE: %@ - %@", [message objectForKey:@"subject"], [reply objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:reply.createdAt];
    }
	else {
		cell.senderName.text = [message objectForKey:@"sender_name"];
        cell.subjectLabel.text = [NSString stringWithFormat:@"%@ - %@", [message objectForKey:@"subject"], [message objectForKey:@"body"]];
        cell.dateSent.text = [self formattedDateString:message.createdAt];
    }
    
    if ([[message objectForKey:@"message_type"] isEqualToString:@"offer"]) {
        [[cell offerPic] setHidden:NO];
        [[cell offerPic] setImage:[UIImage imageNamed:@"ico_message_coupon"]];
    }
	else if ([[message objectForKey:@"message_type"] isEqualToString:@"gift"]) {
        [[cell offerPic] setHidden:NO];
        [[cell offerPic] setImage:[UIImage imageNamed:@"message_gift"]];
    }
	//else if ([[message objectForKey:@"message_type"] isEqualToString:@"feedback"]) {
    //    [[cell offerPic] setHidden:NO];
    //    [[cell offerPic] setImage:[UIImage imageNamed:@"message_reply"]];
    //}
	else {
		[[cell offerPic] setHidden:YES];
	}
    
    if ([[messageStatus objectForKey:@"is_read"] boolValue]) {
        cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
		cell.senderName.font = [RepunchUtils repunchFontWithSize:17 isBold:NO];
		cell.dateSent.font = [RepunchUtils repunchFontWithSize:14 isBold:NO];
		cell.dateSent.textColor = [UIColor darkGrayColor];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
		cell.senderName.font = [RepunchUtils repunchFontWithSize:17 isBold:YES];
		cell.dateSent.font = [RepunchUtils repunchFontWithSize:14 isBold:YES];
		cell.dateSent.textColor = [RepunchUtils repunchOrangeColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IncomingMessageViewController *messageVC = [[IncomingMessageViewController alloc] init];
	PFObject *messageStatus;
	
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) { // All Messages
		messageStatus = self.messagesArray[indexPath.row];
	}
	else if(filter == 1) { // Offers
		messageStatus = self.offersArray[indexPath.row];
	}
	else { // Gifts
		messageStatus = self.giftsArray[indexPath.row];
	}
	
    messageVC.messageStatusId = [messageStatus objectId];
	messageVC.delegate = self;
	messageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageVC animated:YES];
	 
	if( [[messageStatus objectForKey:@"is_read"] boolValue] == NO ) {
		--alertBadgeCount;
		[self updateBadgeCount];
		
		[messageStatus setObject:[NSNumber numberWithBool:YES] forKey:@"is_read"];
		[messageStatus saveEventually];
	
		[self.tableViewController.tableView beginUpdates];
		[self.tableViewController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		[self.tableViewController.tableView endUpdates];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}
  
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollLocation = MIN(scrollView.contentSize.height, scrollView.bounds.size.height) + scrollView.contentOffset.y - scrollView.contentInset.bottom;
    float scrollHeight = MAX(scrollView.contentSize.height, scrollView.bounds.size.height);

    if(scrollLocation >= scrollHeight + 5 && !loadInProgress && !paginateReachEnd)
	{
		[self loadInbox:YES];
    }
}

- (void)setFooter:(BOOL)paginateInProgress
{
	UIView *footer = self.tableViewController.tableView.tableFooterView;
	CGRect footerFrame = footer.frame;
	footerFrame.size.height = paginateInProgress ? 50 : 1;
	footer.frame = footerFrame;
	self.tableViewController.tableView.tableFooterView = footer;
	
	if(paginateInProgress) {
		paginateSpinner.frame = self.tableViewController.tableView.tableFooterView.bounds;
		[self.tableViewController.tableView.tableFooterView addSubview:paginateSpinner];
		[paginateSpinner startAnimating];
	}
	else {
		[paginateSpinner removeFromSuperview];
		[paginateSpinner stopAnimating];
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
	PFObject *messageStatus = [self.sharedData getMessage:msgStatusId];
	
	for(PFObject* messageStatus in self.messagesArray) //if this is a reply, replace the original message
	{
		if( [messageStatus.objectId isEqualToString:msgStatusId] )
		{
			if( ![[messageStatus objectForKey:@"is_read"] boolValue] ) { //avoid incrementing badge count if it was already unread
				--alertBadgeCount;
			}
			[self removeMessage:messageStatus];
			break;
		}
	}
	
	[self addMessage:messageStatus fromPush:YES];
	[self refreshTableView];
	
	++alertBadgeCount;
	[self updateBadgeCount];
}

- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(PFObject *)msgStatus
{
	//no need to update alert badge count because only read messages can be deleted
	NSLog(@"IncomingMessageVC->InboxVC IncomingMessageVCDelegate");
	if(msgStatus != nil) {
		[self removeMessage:msgStatus];
	}
    [self refreshTableView];
}

- (void)addMessage:(PFObject *)messageStatus fromPush:(BOOL)isPush
{
	PFObject *message = [messageStatus objectForKey:@"Message"];
	NSString *messageType = [message objectForKey:@"message_type"];
	
	if(isPush) {
		[self.messagesArray insertObject:messageStatus atIndex:0];
		
		if ([messageType isEqualToString:@"offer"]) {
			[self.offersArray insertObject:messageStatus atIndex:0];
		}
		else if ([messageType isEqualToString:@"gift"]) {
			[self.giftsArray insertObject:messageStatus atIndex:0];
		}
	}
	else {
		[self.messagesArray addObject:messageStatus];
		
		if ([messageType isEqualToString:@"offer"]) {
			[self.offersArray addObject:messageStatus];
		}
		else if ([messageType isEqualToString:@"gift"]) {
			[self.giftsArray addObject:messageStatus];
		}
	}
}

- (void)removeMessage:(PFObject *)messageStatus
{
	[self.messagesArray removeObject:messageStatus];
	
	PFObject *message = [messageStatus objectForKey:@"Message"];
	NSString *messageType = [message objectForKey:@"message_type"];
	
	if ([messageType isEqualToString:@"offer"]) {
		[self.offersArray removeObject:messageStatus];
	}
	else if ([messageType isEqualToString:@"gift"]) {
		[self.giftsArray removeObject:messageStatus];
	}
}

- (void)refreshTableView
{
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) { // All Messages
		if(self.messagesArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"Inbox is empty.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	else if(filter == 1) { // Offers
		if(self.offersArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"No offers yet.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	else { // Gifts
		if(self.giftsArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"No gifts yet.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	
	[self.tableViewController.tableView reloadData];
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
	[currentInstallation saveEventually];
}

- (void)openSettings
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	settingsVC.hidesBottomBarWhenPushed = YES;
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}

- (void)openSearch
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
	searchVC.hidesBottomBarWhenPushed = YES;
	UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:searchVC];
	[RepunchUtils setupNavigationController:searchNavController];
    [self presentViewController:searchNavController animated:YES completion:nil];
}

- (void)showPunchCode
{
	NSString *punchCode = [self.patron objectForKey:@"punch_code"];
	[RepunchUtils showPunchCode:punchCode];
}

@end
