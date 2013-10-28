//
//  StoreViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreViewController.h"

@implementation StoreViewController
{
	DataManager *sharedData;
	PFObject *store;
	PFObject *patron;
	PFObject *patronStore;
	BOOL patronStoreExists;
    int punchCount;
	id selectedReward;
	UIBarButtonItem *deleteButton;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkPatronStore)
												 name:@"Punch"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkPatronStore)
												 name:@"Redeem"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkPatronStore)
												 name:@"FacebookPost"
											   object:nil];
    
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patron = [sharedData patron];
	self.rewardArray = [NSMutableArray array];
	
	[[NSBundle mainBundle] loadNibNamed:@"StoreHeaderView" owner:self options:nil];
	
	[self.addToMyPlacesButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.addToMyPlacesButton]
								   forState:UIControlStateNormal];
	[self.addToMyPlacesButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.addToMyPlacesButton]
								   forState:UIControlStateHighlighted];
	
	deleteButton = [[UIBarButtonItem alloc]
									 initWithImage:[UIImage imageNamed:@"nav_delete.png"]
									 style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(deleteStore:)];
	
	
	[self setStoreInformation];
	[self checkPatronStore];
	[self setRewardTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkPatronStore
{
    patronStore = [sharedData getPatronStore:self.storeId];
    patronStoreExists = (patronStore != nil);
	
	if(patronStoreExists) {
		punchCount = [[patronStore objectForKey:@"punch_count"] intValue];
		
		PFObject *facebookPost = [patronStore objectForKey:@"FacebookPost"];
		if( !IS_NIL(facebookPost) )
		{
			NSString *rewardTitle = [facebookPost objectForKey:@"reward"];
			[FacebookPost presentDialog:self.storeId withRewardTitle:rewardTitle];
		}
	}
	else
	{
		punchCount = 0;
	}
	
	[self setStoreButtons];
    [self.rewardTableView reloadData];
}

- (void)setStoreInformation
{	
	NSString *name = [store objectForKey:@"store_name"];
	NSString *street = [store objectForKey:@"street"];
	NSString *crossStreets = [store objectForKey:@"cross_streets"];
	NSString *neighborhood = [store objectForKey:@"neighborhood"];
	NSString *city = [store objectForKey:@"city"];
	NSString *state = [store objectForKey:@"state"];
	NSString *zip = [store objectForKey:@"zip"];
	//NSString *category = [store objectForKey:@"categories"];
	self.rewardArray = [store objectForKey:@"rewards"];

	self.navigationItem.title = name;
	
	if( !IS_NIL(crossStreets) ) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:crossStreets];		
	}
	
	if( !IS_NIL(neighborhood) ) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:neighborhood];
	}
	
	street = [street stringByAppendingString:@"\n"];
	street = [street stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@", city, @", ", state, @" ", zip]];
	
	self.storeAddress.text = street;
	[self.storeAddress sizeToFit];
	
	[self setStoreHours];
	
	PFFile *imageFile = [store objectForKey:@"store_avatar"];
	if( !IS_NIL(imageFile) )
	{
		UIImage *storeImage = [sharedData getStoreImage:self.storeId];
		if(storeImage == nil)
		{
			self.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
			[imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
			 {
				 if (!error) {
					 UIImage *storeImage = [UIImage imageWithData:data];
					 self.storeImage.image = storeImage;
					 [sharedData addStoreImage:storeImage forKey:self.storeId];
				 }
				 else
				 {
					 NSLog(@"image download failed");
					 [RepunchUtils showConnectionErrorDialog];
				 }
			 }];
		} else {
			self.storeImage.image = storeImage;
		}
	} else {
		self.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
	}
}

- (void)setStoreHours
{
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"h:mm a"];

	NSArray *hoursArray = [store objectForKey:@"hours"];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
										   fromDate:[NSDate date]];
	int weekday = [comps weekday];

	NSDate *now = [gregorian dateFromComponents:comps];
	
	NSDictionary *today;
	
	for(NSDictionary *hours in hoursArray)
	{
		if ([[hours objectForKey:@"day"] integerValue] == weekday) {
			today = hours;
			break;
		}
	}
	
	if(today == nil) {
		self.storeHoursOpen.hidden = YES;
		self.storeHoursToday.hidden = YES;
		self.storeHours.hidden = YES;
		return;
	}
	
	NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
	inFormat.dateFormat = @"HHmm";
	NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
	outFormat.dateFormat = @"h:mm a";
	outFormat.timeZone = [NSTimeZone systemTimeZone];
	//[inFormat setLocale:[NSLocale currentLocale]];
	NSDate *openTime = [inFormat dateFromString:[today objectForKey:@"open_time"]];
	NSDate *closeTime = [inFormat dateFromString:[today objectForKey:@"close_time"]];
	
	NSDateComponents *compsOpen = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
										   fromDate:openTime];
	NSDateComponents *compsClose = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
											   fromDate:closeTime];
	openTime = [gregorian dateFromComponents:compsOpen];
	closeTime = [gregorian dateFromComponents:compsClose];
	
	NSString *openTimeFormatted = [outFormat stringFromDate:openTime];
	NSString *closeTimeFormatted = [outFormat stringFromDate:closeTime];
	
	if([now compare:openTime] != NSOrderedAscending && [now compare:closeTime] == NSOrderedAscending)
	{
		self.storeHoursOpen.text = @"Open";
		self.storeHoursOpen.textColor = [UIColor colorWithRed:0.0 green:(204/255.0) blue:0.0 alpha:1.0];
	}
	else
	{
		self.storeHoursOpen.text = @"Closed";
		self.storeHoursOpen.textColor = [UIColor colorWithRed:(224/255.0) green:0.0 blue:0.0 alpha:1.0];
	}
	
	self.storeHours.text = [NSString stringWithFormat:@"%@ - %@", openTimeFormatted, closeTimeFormatted];
	[self.storeHours sizeToFit];
}

- (void)setStoreButtons
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	
	if(!patronStoreExists)
	{
		[self.addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
		[self.addToMyPlacesButton setEnabled:YES];
		[self.addToMyPlacesButton addTarget:self
									 action:@selector(addStore)
						   forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = nil;
		
		self.feedbackButton.hidden = YES;
		
		CGPoint callButtonCenter = self.callButton.center;
		callButtonCenter.x = screenWidth/4;
		self.callButton.center = callButtonCenter;
		
		CGPoint mapButtonCenter = self.mapButton.center;
		mapButtonCenter.x = screenWidth*3/4;
		self.mapButton.center = mapButtonCenter;
	}
	else
	{
		NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
		[self.addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
		[self.addToMyPlacesButton setEnabled:YES];
		self.navigationItem.rightBarButtonItem = deleteButton;
		
		self.feedbackButton.hidden = NO;
		
		CGPoint callButtonCenter = self.callButton.center;
		callButtonCenter.x = screenWidth/6;
		self.callButton.center = callButtonCenter;
		
		CGPoint mapButtonCenter = self.mapButton.center;
		mapButtonCenter.x = screenWidth/2;
		self.mapButton.center = mapButtonCenter;
		
		CGPoint feedbackButtonCenter = self.feedbackButton.center;
		feedbackButtonCenter.x = screenWidth*5/6;
		self.feedbackButton.center = feedbackButtonCenter;
	}
}

- (void)setRewardTableView
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
	self.rewardTableView = [[UITableView alloc]
							  initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - navBarHeight)
							  style:UITableViewStylePlain];
	
    [self.rewardTableView setDataSource:self];
    [self.rewardTableView setDelegate:self];
    [self.view addSubview:self.rewardTableView];
	
	self.rewardTableView.tableHeaderView = self.headerView;
	
	self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(refreshPatronStoreObject)
									  forControlEvents:UIControlEventValueChanged];
	self.tableViewController.tableView = self.rewardTableView;
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
	footer.backgroundColor = [UIColor clearColor];
	self.rewardTableView.tableFooterView = footer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rewardArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RewardTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [RewardTableViewCell cell];
    }
	
	id reward = [self.rewardArray objectAtIndex:indexPath.row];
    
    cell.rewardTitle.text = [reward objectForKey:@"reward_name"];
    cell.rewardDescription.text = [reward objectForKey:@"description"];
    int rewardPunches = [[reward objectForKey:@"punches"] intValue];
    cell.rewardPunches.text = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];
    
	if (punchCount < rewardPunches) {
        cell.rewardStatusIcon.image = [UIImage imageNamed:@"reward_locked"];
    } else {
		cell.rewardStatusIcon.image = [UIImage imageNamed:@"reward_unlocked"];
	}
    
    [cell setUserInteractionEnabled:patronStoreExists];
	
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 93;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!patronStoreExists) {
		return;
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	id reward = [self.rewardArray objectAtIndex:indexPath.row];
	selectedReward = reward;

	int rewardPunches = [[reward objectForKey:@"punches"] intValue];
	int rewardId = [[reward objectForKey:@"reward_id"] intValue];
	NSString *rewardPunchesString = [NSString stringWithFormat:@"%d", rewardPunches];
	NSString *rewardIdString = [NSString stringWithFormat:@"%d", rewardId];
	NSString *rewardName = [reward objectForKey:@"reward_name"];
	NSString *patronName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
	
	
	NSString *str1 = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];
	NSString *message = [[reward objectForKey:@"description"] stringByAppendingFormat:@"\n\n%@", str1];

	SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[reward objectForKey:@"reward_name"]
														 andMessage:message];
	
	if (punchCount >= rewardPunches)
	{
		[alertView addButtonWithTitle:@"Redeem"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert)
		{
			NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:
													patron.objectId,			@"patron_id",
													store.objectId,				@"store_id",
													patronStore.objectId,		@"patron_store_id",
													rewardName,					@"title",
													rewardIdString,				@"reward_id",
													rewardPunchesString,		@"num_punches",
													patronName,					@"name",
													nil];

			[PFCloud callFunctionInBackground:@"request_redeem"
							   withParameters:functionArguments
										block:^(NSString *success, NSError *error)
			{
				if (!error)
				{
					if ([success isEqualToString:@"pending"])
					{
						NSLog(@"function call is: %@", success);
						SIAlertView *confirmDialogue = [[SIAlertView alloc] initWithTitle:@"Pending" andMessage:@"You already have a pending reward"];
						[confirmDialogue addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
							//nothing
						}];
						[confirmDialogue show];
					}
					else
					{
						NSLog(@"function call is: %@", success);
						SIAlertView *confirmDialogue = [[SIAlertView alloc] initWithTitle:@"Waiting for confirmation" andMessage:@"Please wait for your reward to be validated"];
						[confirmDialogue addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
							//nothing4
						}];
						[confirmDialogue show];
					}
				}
				else
				{
					NSLog(@"error occurred: %@", error);
					[RepunchUtils showConnectionErrorDialog];
				}
			}];
		}];

		[alertView addButtonWithTitle:@"Gift"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert)
		 {
			 [self gift];
		 }];
            
		[alertView addButtonWithTitle:@"Cancel"
								 type:SIAlertViewButtonTypeDefault
							  handler:nil];
	}
	else
	{
		[alertView addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:nil];
	}
	
	[alertView show];
}

- (IBAction)callButtonAction:(id)sender
{
	//[self.callButtonView setBackgroundColor:[UIColor clearColor]];
	
    NSString *number = [store objectForKey:@"phone_number"];
    NSString *phoneNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]"
															  withString:@""
																 options:NSRegularExpressionSearch
																   range:NSMakeRange(0, [number length])];
	
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];
}

- (IBAction)mapButtonAction:(id)sender
{
	StoreMapViewController *storeMapVC = [[StoreMapViewController alloc] init];
	storeMapVC.storeId = self.storeId;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:storeMapVC];
	[RepunchUtils setupNavigationController:navController];
	
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)feedbackButtonAction:(id)sender
{
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.messageType = @"feedback"; //TODO: make this enum
	composeVC.storeId = self.storeId;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:composeVC];
	[RepunchUtils setupNavigationController:navController];
	
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)addStore
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showNavigationBarDropdownView:self.view];
		return;
	}
	
	[self.addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[self.addToMyPlacesButton setEnabled:NO];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.addToMyPlacesButton.bounds;
	[self.addToMyPlacesButton addSubview:spinner];
	spinner.hidesWhenStopped = YES;
	[spinner startAnimating];
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
									[patron objectId],		@"patron_id",
									[store objectId],		@"store_id",
									nil];
	
	[PFCloud callFunctionInBackground: @"add_patronstore"
					   withParameters:inputArgs
								block:^(PFObject *result, NSError *error)
	{
		[spinner stopAnimating];
		
		if(!error)
		{
			[sharedData addPatronStore:result forKey:self.storeId];
			[self checkPatronStore];
			[self alertParentViewController:YES];
		}
		else
		{
			NSLog(@"add_patronStore error: %@", error);
			[self.addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
			[RepunchUtils showConnectionErrorDialog];
		}
	}];
}

- (IBAction)deleteStore:(id)sender
{
	SIAlertView *warningView = [[SIAlertView alloc] initWithTitle:@"Remove from My Places"
													   andMessage:@"WARNING: You will lose all your punches!"];
	[warningView addButtonWithTitle:@"Cancel"
							   type:SIAlertViewButtonTypeDefault
							handler:^(SIAlertView *alert) {
								[alert dismissAnimated:YES];
							}];
	
	[warningView addButtonWithTitle:@"Remove"
							   type:SIAlertViewButtonTypeDestructive
							handler:^(SIAlertView *alert) {
								[self performDelete];
								[alert dismissAnimated:YES];
							}];
	[warningView show];
}

- (void)performDelete
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showNavigationBarDropdownView:self.view];
		return;
	}
	
	[self.addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[self.addToMyPlacesButton setEnabled:NO];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.addToMyPlacesButton.bounds;
	[self.addToMyPlacesButton addSubview:spinner];
	spinner.hidesWhenStopped = YES;
	[spinner startAnimating];
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							   [patronStore objectId],	@"patron_store_id",
							   [patron objectId],		@"patron_id",
							   [store objectId],		@"store_id",
							   nil];
	
	[PFCloud callFunctionInBackground: @"delete_patronstore"
					   withParameters:inputArgs
								block:^(NSString *result, NSError *error)
	 {
		 [spinner stopAnimating];
		 
		 if(!error)
		 {
			 [sharedData deletePatronStore:self.storeId];
			 [self checkPatronStore];
			 [self.rewardTableView reloadData];
			 [self alertParentViewController:YES];
		 }
		 else
		 {
			 NSLog(@"delete_patronStore error: %@", error);
			 NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
			 [self.addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
			 [RepunchUtils showConnectionErrorDialog];
		 }
	 }];
}

- (void)gift
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showNavigationBarDropdownView:self.view];
		return;
	}
	
	if( [patron objectForKey:@"facebook_id"] == nil)
	{
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"It's better together"]
														 andMessage:@"Log in with Facebook to send gifts to your friends"];
	
		[alertView addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
							  }];
		[alertView show];
	}
	else
	{
		FacebookFriendsViewController *facebookFriendsVC = [[FacebookFriendsViewController alloc] init];
		facebookFriendsVC.myDelegate = self;
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:facebookFriendsVC];
		[RepunchUtils setupNavigationController:navController];
		
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (void)refreshPatronStoreObject
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[self.tableViewController.refreshControl endRefreshing];
		[RepunchUtils showNavigationBarDropdownView:self.view];
		return;
	}
	
	if(patronStoreExists)
	{
		PFQuery *query = [PFQuery queryWithClassName:@"PatronStore"];
		[query includeKey:@"Store"];
		[query getObjectInBackgroundWithId:patronStore.objectId block:^(PFObject *result, NSError *error)
		 {
			 if(!error)
			 {
				 patronStore = result;
				 store = [result objectForKey:@"Store"];
				 [sharedData addPatronStore:patronStore forKey:self.storeId];
				 [sharedData addStore:store];
				 [self setStoreInformation];
				 [self checkPatronStore];
				 [self setRewardTableView];
			 }
			 else
			 {
				 NSLog(@"error fetching Store: %@", error);
				 [RepunchUtils showConnectionErrorDialog];
			 }
		 }];
	}
	else
	{
		PFQuery *query = [PFQuery queryWithClassName:@"Store"];
		[query getObjectInBackgroundWithId:self.storeId block:^(PFObject *result, NSError *error)
		{
			 if(!error)
			 {
				 store = result;
				 [sharedData addStore:store];
				 [self setStoreInformation];
				 [self setRewardTableView];
			 }
			 else
			 {
				 NSLog(@"error fetching Store: %@", error);
				 [RepunchUtils showConnectionErrorDialog];
			 }
		 }];
	}
}

- (void)onFriendSelected:(FacebookFriendsViewController *)controller forFriendId:(NSString *)friendId withName:(NSString *)name
{
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.messageType = @"gift";
	composeVC.storeId = self.storeId;
	composeVC.giftRecepientId = friendId;
	composeVC.giftTitle = [selectedReward objectForKey:@"reward_name"];
	composeVC.giftDescription = [selectedReward objectForKey:@"description"];
	composeVC.giftPunches = [[selectedReward objectForKey:@"punches"] intValue];
	composeVC.recepientName = name;
	
	UINavigationController *composeNavController = [[UINavigationController alloc] initWithRootViewController:composeVC];
	[RepunchUtils setupNavigationController:composeNavController];
	
	[self presentViewController:composeNavController animated:YES completion:nil];
}

- (void)alertParentViewController:(BOOL)isAddRemove
{
    if ([self.delegate respondsToSelector:@selector(updateTableViewFromStore:forStoreId:andAddRemove:)]) {
        //[self.delegate updateTableViewFromStore:self forStoreId:self.storeId andAddRemove:isAddRemove];
		NSLog(@"Yeah this happens");
    }
	[self.delegate updateTableViewFromStore:self forStoreId:self.storeId andAddRemove:isAddRemove];
}

@end
