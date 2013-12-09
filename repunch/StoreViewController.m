//
//  StoreViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreViewController.h"
#import "RPStore.h"

@implementation StoreViewController
{
	DataManager *sharedData;
	RPStore *store;
	PFObject *patron;
	PFObject *patronStore;
	BOOL patronStoreExists;
    int punchCount;
	id selectedReward;
	UIBarButtonItem *deleteButton;
    NSMutableArray *timers;
    CGRect headerFrame;


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
	store = (RPStore*)[sharedData getStore:self.storeId];
	patron = [sharedData patron];
	
	[[NSBundle mainBundle] loadNibNamed:@"StoreHeaderView" owner:self options:nil];
	
	[RepunchUtils setDefaultButtonStyle:self.addToMyPlacesButton];
	[self.addToMyPlacesButton setClipsToBounds:NO];
	
	deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete_icon.png"]
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(deleteStore)];
    headerFrame = self.headerView.frame;

	[self setStoreInformation];
	[self checkPatronStore];
	[self setRewardTableView];
    [self fixHeaderSize];

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
	self.navigationItem.title = store.store_name;
	
	self.storeAddress.text = store.formattedAddress;
	[self.storeAddress sizeToFit];
	
    [self setStoreHours];

    __weak typeof(self) weakSelf = self;
    
    [store updateStoreAvatarWithCompletionHander:^(RPStore *store, UIImage *avatar, RPErrorCode errorCode) {
        
        if (avatar) {
            weakSelf.storeImage.image = avatar; // if there is some error it will give same image back
        }
        else {
            weakSelf.storeImage.image = [UIImage imageNamed:@"listview_placeholder"];
        }
        
        weakSelf.storeImage.layer.masksToBounds = YES;
        weakSelf.storeImage.layer.cornerRadius = 10;
        [weakSelf.storeImage setNeedsDisplay];
    }];
    
}

#pragma mark - Store Hours & header size fixer
- (void)setStoreHours
{
    RPStoreHours *hours = store.hoursManager;
    
    if (hours.isOpenAlways) {
        self.storeHoursToday.hidden = NO;
        self.storeHours.hidden = NO;
        self.storeHoursOpen.hidden = NO;
        
        self.storeHoursOpen.text = NSLocalizedString(@"Open", nil);
        self.storeHoursOpen.textColor = [UIColor colorWithRed:0.0 green:(204/255.0) blue:0.0 alpha:1.0];
        self.storeHours.text = @"Open 24/7";
    }
    else if(hours){
        
        self.storeHoursToday.hidden = NO;
        self.storeHours.hidden = NO;
        self.storeHoursOpen.hidden = NO;
        self.storeHours.text = @"";
        
        NSArray *repunchDates = [hours hoursForToday];
        
        NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
        outFormat.dateFormat = @"h:mm a";
        
        NSMutableString *fullString = [[NSMutableString alloc] init];
        
        for (NSDictionary *hours in repunchDates) {
            
            NSDate *open = hours[kOpenTime];
            NSDate *close = hours[kCloseTime];
            
            NSString *openString = [outFormat stringFromDate:open];
            NSString *closeString = [outFormat stringFromDate:close];
            
            [fullString appendString:[NSString stringWithFormat:@"%@ - %@\n", openString, closeString ]];
        }
        
        self.storeHours.text = [fullString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Set Indicator
        if(hours.isOpenNow) {
            self.storeHoursOpen.text = NSLocalizedString(@"Open", nil);
            self.storeHoursOpen.textColor = [UIColor colorWithRed:0.0 green:(204/255.0) blue:0.0 alpha:1.0];
        }
        else {
            self.storeHoursOpen.text = NSLocalizedString(@"Closed", nil);
            self.storeHoursOpen.textColor = [UIColor colorWithRed:(224/255.0) green:0.0 blue:0.0 alpha:1.0];
        }
    }
    else {
        // If no hours are set
        self.storeHours.text = @"";
        self.storeHoursToday.hidden = YES;
        self.storeHours.hidden = YES;
        self.storeHoursOpen.hidden = YES;
    }
    
    [self fixHeaderSize];
}

- (void)fixHeaderSize
{
    [self.storeHours sizeToFit];
    
    if (self.storeHours.frame.size.height > 20 && !self.storeHours.hidden) {
        // Resize Header if more than one line
        UIView *header = self.tableViewController.tableView.tableHeaderView;
        CGRect frame = headerFrame;
        
        frame.size.height += abs(25 - self.storeHours.frame.size.height);
        header.frame = frame;
        
       self.tableViewController.tableView.tableHeaderView = header;
    }
    else {
        CGRect frame = headerFrame;
        
        if (self.storeHours.hidden) {
            frame.size.height -= 20;
        }
        UIView *header = self.tableViewController.tableView.tableHeaderView;
        header.frame = frame;
        self.tableViewController.tableView.tableHeaderView = header;
    }
    
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
		[self.addToMyPlacesButton setEnabled:NO];
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
	[self.tableViewController.refreshControl setTintColor:[RepunchUtils repunchOrangeColor]];
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
    return store.rewards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RewardTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [RewardTableViewCell cell];
    }
	
	id reward = store.rewards[indexPath.row];
    
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
	id reward = store.rewards[indexPath.row];
	selectedReward = reward;

	int rewardPunches = [[reward objectForKey:@"punches"] intValue];
	int rewardId = [[reward objectForKey:@"reward_id"] intValue];
	NSString *rewardPunchesString = [NSString stringWithFormat:@"%d", rewardPunches];
	NSString *rewardIdString = [NSString stringWithFormat:@"%d", rewardId];
	NSString *rewardName = [reward objectForKey:@"reward_name"];
	NSString *patronName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
	
	
	NSString *str1 = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];
	NSString *message = [str1 stringByAppendingFormat:@"\n\n%@", [reward objectForKey:@"description"]];

	SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[reward objectForKey:@"reward_name"]
													 andMessage:message];
	
	if (punchCount >= rewardPunches)
	{
		[alertView addButtonWithTitle:@"Redeem"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
								  
			if( ![RepunchUtils isConnectionAvailable] ) {
				[RepunchUtils showDefaultDropdownView:self.view];
				return;
			}
								  
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
										block:^(NSString *success, NSError *error) {
				if (!error)
				{
					if ([success isEqualToString:@"pending"])
					{
						NSLog(@"function call is: %@", success);
						[RepunchUtils showDialogWithTitle:@"Pending"
											  withMessage:@"You can only request one reward at a time. Please wait for your reward to be approved."];
					}
					else
					{
						NSLog(@"function call is: %@", success);
						[RepunchUtils showDialogWithTitle:@"Waiting for confirmation"
											  withMessage:@"Please wait for your reward to be approved"];
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
							  handler:^(SIAlertView *alert) {
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
    NSString *phoneNumber = [store.phone_number stringByReplacingOccurrencesOfString:@"[^0-9]"
															  withString:@""
																 options:NSRegularExpressionSearch
																   range:NSMakeRange(0, store.phone_number.length)];
	
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
		[RepunchUtils showDefaultDropdownView:self.view];
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
									patron.objectId,		@"patron_id",
									store.objectId,			@"store_id",
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
			
			NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:self.storeId, @"store_id", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:args];
		}
		else
		{
			NSLog(@"add_patronStore error: %@", error);
			[self.addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
			[RepunchUtils showConnectionErrorDialog];
		}
	}];
}

- (void)deleteStore
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
		[RepunchUtils showDefaultDropdownView:self.view];
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
							   patronStore.objectId,	@"patron_store_id",
							   patron.objectId,			@"patron_id",
							   store.objectId,			@"store_id",
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
         
			 NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:self.storeId, @"store_id", nil];
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:args];
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
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if( [patron objectForKey:@"facebook_id"] == nil)
	{
		[RepunchUtils showDialogWithTitle:@"It's better together"
							  withMessage:@"Log in with Facebook to send gifts to your friends"];
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
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(patronStoreExists)
	{
		PFQuery *query = [PFQuery queryWithClassName:@"PatronStore"];
		[query includeKey:@"Store"];
		[query includeKey:@"FacebookPost"];
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
				 
				 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:nil];
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
		PFQuery *query = [RPStore query];
		[query getObjectInBackgroundWithId:self.storeId block:^(PFObject *result, NSError *error)
		{
			 if(!error)
			 {
				 store = (RPStore *)result;
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

@end
