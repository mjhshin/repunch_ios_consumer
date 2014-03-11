//
//  InboxViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "InboxViewController.h"
#import "RPPullToRefreshView.h"

#define PAGINATE_INCREMENT 20

@interface InboxViewController ()
//@property (strong, nonatomic) RPReloadControl *reloadControl;
@end

@implementation InboxViewController
{
	DataManager *dataManager;
	RPPatron *patron;
	NSMutableArray *messagesArray;
	NSMutableArray *offersArray;
	NSMutableArray *giftsArray;
	
	NSInteger alertBadgeCount;
	BOOL loadInProgress;
	int paginateCount;
	BOOL paginateReachEnd;
	UISegmentedControl *segmentedControl;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	dataManager = [DataManager getSharedInstance];
    patron = [dataManager patron];
	messagesArray = [[NSMutableArray alloc] init];
	offersArray = [[NSMutableArray alloc] init];
	giftsArray = [[NSMutableArray alloc] init];
	
	alertBadgeCount = 0;
	paginateCount = 0;
	loadInProgress = NO;
	paginateReachEnd = NO;

	[self registerForNotifications];
	[self setupNavigationBar];
    [self loadInbox:NO];
	
	__weak typeof(self) weakSelf = self;
	[self.tableView addPullToRefreshActionHandler:^{
		[weakSelf loadInbox:NO];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0); //workaround. top inset initially being set to 128
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
	
	Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
	__weak typeof(self) weakSelf = self;
	reach.reachableBlock = ^(Reachability *reach) {
		if(messagesArray.count == 0) {
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
									   initWithImage:[UIImage imageNamed:@"nav_settings"]
									   style:UIBarButtonItemStylePlain
									   target:self
									   action:@selector(openSettings)];
	
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"nav_search"]
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

- (void)loadInbox:(BOOL)paginate
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[self.tableView stopRefreshAnimation];
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(loadInProgress) {
		return;
	}
	
	loadInProgress = YES;
	
    PFRelation *messagesRelation = [patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
    [messageQuery includeKey:@"Message.Reply"];
	[messageQuery orderByDescending:@"createdAt"];
	messageQuery.limit = PAGINATE_INCREMENT;
	
	if(paginate == YES) {
		++paginateCount;
		messageQuery.skip = paginateCount * PAGINATE_INCREMENT;
		
		[self.tableView setPaginationFooter];
	}
	else if(messagesArray.count == 0) {
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
		self.emptyInboxLabel.hidden = YES;
	}
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
		if(paginate == YES) {
			[self.tableView setDefaultFooter];
		}
		else {
			self.activityIndicatorView.hidden = YES;
			[self.activityIndicator stopAnimating];
            [self.tableView stopRefreshAnimation];
		}
		
        if(!error) {
            if (paginate != YES) {
                [messagesArray removeAllObjects];
				[offersArray removeAllObjects];
				[giftsArray removeAllObjects];
				
                paginateReachEnd = NO;
				paginateCount = 0;
				[self fetchBadgeCount];
            }

			for(RPMessageStatus *messageStatus in results) {
				[dataManager addMessage:messageStatus];
				[self addMessage:messageStatus fromPush:NO];
			}

			[self refreshTableView];
			
			if(paginate == YES && results.count < PAGINATE_INCREMENT) {
				paginateReachEnd = YES;
			}
			
			[self checkForOfferGiftPagination];
        }
		else {
            [RepunchUtils showConnectionErrorDialog];
        }
		
		loadInProgress = NO;
    }];
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
	
	if(filter == 0) {
		return messagesArray.count;
	}
	else if(filter == 1) {
		return offersArray.count;
	}
	else {
		return giftsArray.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[InboxTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [InboxTableViewCell cell];
    }
	
	RPMessageStatus *messageStatus;
	
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) {
		messageStatus = messagesArray[indexPath.row];
	}
	else if(filter == 1) {
		messageStatus = offersArray[indexPath.row];
	}
	else {
		messageStatus = giftsArray[indexPath.row];
	}

    RPMessage *message = messageStatus.Message;
    RPMessage *reply = message.Reply;
    
	cell.senderName.text = IS_NIL(reply) ? message.sender_name : reply.sender_name;
	cell.dateSent.text = IS_NIL(reply) ? [self formattedDateString:message.createdAt]
										: [self formattedDateString:reply.createdAt];
	
	if(message.type == RPMessageTypeOffer || message.type == RPMessageTypeBasic) { // no reply possible here
		cell.messagePreview.text = [NSString stringWithFormat:@"%@ - %@", message.subject, message.body];
	}
	else {
		cell.messagePreview.text = IS_NIL(reply) ? message.body : reply.body;
	}
	
	[cell setMessageTypeIcon:message.type forReadMessage:messageStatus.is_read];
	
    if (messageStatus.is_read) {
		[cell setMessageRead];
    }
    else {
		[cell setMessageUnread];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IncomingMessageViewController *messageVC = [[IncomingMessageViewController alloc] init];
	RPMessageStatus *messageStatus;
	
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) {
		messageStatus = messagesArray[indexPath.row];
	}
	else if(filter == 1) {
		messageStatus = offersArray[indexPath.row];
	}
	else {
		messageStatus = giftsArray[indexPath.row];
	}
	
    messageVC.messageStatusId = messageStatus.objectId;
	messageVC.delegate = self;
	messageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageVC animated:YES];
	 
	if( !messageStatus.is_read )
	{
		--alertBadgeCount;
		[self updateBadgeCount];
		
		messageStatus.is_read = YES;
		[messageStatus saveEventually];
	
		[self.tableView beginUpdates];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView endUpdates];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}
  
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat scrollOffset = MIN(scrollView.contentSize.height, scrollView.bounds.size.height);
    CGFloat scrollLocation = scrollOffset + scrollView.contentOffset.y - scrollView.contentInset.bottom;
    CGFloat scrollHeight = MAX(scrollView.contentSize.height, scrollView.bounds.size.height) + 5;

    if(scrollLocation >= scrollHeight && !loadInProgress && !paginateReachEnd)
	{
		[self loadInbox:YES];
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
	NSString *msgStatusId = notification.userInfo[@"message_status_id"];
	RPMessageStatus *messageStatus = [dataManager getMessage:msgStatusId];
	
	for(RPMessageStatus* messageStatus in messagesArray) //if this is a reply, replace the original message
	{
		if( [messageStatus.objectId isEqualToString:msgStatusId] )
		{
			if( !messageStatus.is_read ) { //avoid incrementing badge count if it was already unread
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

- (void)removeMessage:(IncomingMessageViewController *)controller forMsgStatus:(RPMessageStatus *)messageStatus
{
	//no need to update alert badge count because only read messages can be deleted
	NSLog(@"IncomingMessageVC->InboxVC IncomingMessageVCDelegate");
	if(messageStatus != nil) {
		[self removeMessage:messageStatus];
	}
	else {
		[self sortMessagesByDate];
	}
    [self refreshTableView];
}

- (void)addMessage:(RPMessageStatus *)messageStatus fromPush:(BOOL)isPush
{
	RPMessage *message = messageStatus.Message;
	
	if(isPush) {
		[messagesArray insertObject:messageStatus atIndex:0];
		
		if (message.type == RPMessageTypeOffer) {
			[offersArray insertObject:messageStatus atIndex:0];
		}
		else if (message.type == RPMessageTypeGift) {
			[giftsArray insertObject:messageStatus atIndex:0];
		}
	}
	else {
		[messagesArray addObject:messageStatus];
		
		if (message.type == RPMessageTypeOffer) {
			[offersArray addObject:messageStatus];
		}
		else if (message.type == RPMessageTypeGift) {
			[giftsArray addObject:messageStatus];
		}
	}
}

- (void)removeMessage:(RPMessageStatus *)messageStatus
{
	[messagesArray removeObject:messageStatus];
	
	RPMessage *message = messageStatus.Message;
	
	if (message.type == RPMessageTypeOffer) {
		[offersArray removeObject:messageStatus];
	}
	else if (message.type == RPMessageTypeGift) {
		[giftsArray removeObject:messageStatus];
	}
}

- (void)refreshTableView
{
	NSInteger filter = segmentedControl.selectedSegmentIndex;
	
	if(filter == 0) {
		if(messagesArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"Inbox is empty.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	else if(filter == 1) {
		if(offersArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"No offers yet.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	else {
		if(giftsArray.count > 0) {
			[self.emptyInboxLabel setHidden:YES];
		}
		else {
			self.emptyInboxLabel.text = @"No gifts yet.";
			[self.emptyInboxLabel setHidden:NO];
		}
	}
	
	[self.tableView reloadData];
}

- (void)filterMessages
{
	[self refreshTableView];
	
	[self checkForOfferGiftPagination];
}

- (void)checkForOfferGiftPagination
{
	if(!loadInProgress && !paginateReachEnd) {
		if(segmentedControl.selectedSegmentIndex == 1 && offersArray.count < 5) { //offers
			[self loadInbox:YES];
		}
		else if(segmentedControl.selectedSegmentIndex == 2 && giftsArray.count < 5) { // gifts
			[self loadInbox:YES];
		}
	}
}

- (void)fetchBadgeCount
{
	PFRelation *messagesRelation = [patron relationforKey:@"ReceivedMessages"];
    PFQuery *messageQuery = [messagesRelation query];
	[messageQuery whereKey:@"is_read" equalTo:[NSNumber numberWithBool:NO]];
	[messageQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
		
		if (!error) {
			alertBadgeCount = count;
			[self updateBadgeCount];
		} else {
			// Hmmm. Oh well.
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
	
	RPInstallation *installation = [RPInstallation currentInstallation];
	installation.badge = alertBadgeCount;
	[installation saveEventually];
}

- (void)sortMessagesByDate
{
	[messagesArray sortUsingComparator:^NSComparisonResult(RPMessageStatus *msg1, RPMessageStatus *msg2) {
		
		NSDate *date1 = IS_NIL(msg1.Message.Reply) ? msg1.Message.createdAt : msg1.Message.Reply.createdAt;
		NSDate *date2 = IS_NIL(msg2.Message.Reply) ? msg2.Message.createdAt : msg2.Message.Reply.createdAt;
		
		return [date2 compare:date1];
	 }];
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
	[RepunchUtils showPunchCode:patron.punch_code];
}

@end
