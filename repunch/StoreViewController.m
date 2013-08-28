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
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	[[NSBundle mainBundle] loadNibNamed:@"StoreHeaderView" owner:self options:nil];
	
	[self.addToMyPlacesButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.addToMyPlacesButton]
								   forState:UIControlStateNormal];
	[self.addToMyPlacesButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.addToMyPlacesButton]
								   forState:UIControlStateHighlighted];
	
	[self setStoreInformation];
	[self checkPatronStore];
	[self setRewardTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:YES];
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
		if( facebookPost != nil && facebookPost != (id)[NSNull null] )
		{
			NSString *rewardTitle = [facebookPost objectForKey:@"reward"];
			[FacebookUtils postToFacebook:self.storeId withRewardTitle:rewardTitle];
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

	
	self.storeNameLabel.text = name;
	
	if(crossStreets != (id)[NSNull null]) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:crossStreets];		
	}
	
	if(neighborhood != (id)[NSNull null]) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:neighborhood];
	}
	
	street = [street stringByAppendingString:@"\n"];
	street = [street stringByAppendingString:[NSString stringWithFormat:@"%@%@%@%@%@", city, @", ", state, @" ", zip]];
	
	self.storeAddress.text = street;
	[self.storeAddress sizeToFit];
	
	[self setStoreHours];
	
	PFFile *imageFile = [store objectForKey:@"store_avatar"];
	if(imageFile != nil)
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
					 [RepunchUtils showDefaultErrorMessage];
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
		[self.addToMyPlacesButton setEnabled:TRUE];
		[self.addToMyPlacesButton addTarget:self
									 action:@selector(addStore)
						   forControlEvents:UIControlEventTouchUpInside];
		[self.deleteButton setHidden:TRUE];
		
		self.feedbackButtonView.hidden = YES;
		
		CGPoint callButtonCenter = self.callButtonView.center;
		callButtonCenter.x = screenWidth/4;
		self.callButtonView.center = callButtonCenter;
		
		CGPoint mapButtonCenter = self.mapButtonView.center;
		mapButtonCenter.x = screenWidth*3/4;
		self.mapButtonView.center = mapButtonCenter;
	}
	else
	{
		NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
		[self.addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
		[self.addToMyPlacesButton setEnabled:FALSE];
		[self.deleteButton setHidden:FALSE];
		
		self.feedbackButtonView.hidden = NO;
		
		CGPoint callButtonCenter = self.callButtonView.center;
		callButtonCenter.x = screenWidth/6;
		self.callButtonView.center = callButtonCenter;
		
		CGPoint mapButtonCenter = self.mapButtonView.center;
		mapButtonCenter.x = screenWidth/2;
		self.mapButtonView.center = mapButtonCenter;
		
		CGPoint feedbackButtonCenter = self.feedbackButtonView.center;
		feedbackButtonCenter.x = screenWidth*5/6;
		self.feedbackButtonView.center = feedbackButtonCenter;
	}
	
	//set button actions
	[self.callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	[self.mapButton addTarget:self action:@selector(mapButtonPressed) forControlEvents:UIControlEventTouchUpInside];	
	[self.feedbackButton addTarget:self action:@selector(feedbackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	/*
	[self.callButton addTarget:self action:@selector(callButtonTouchDown) forControlEvents:UIControlEventTouchDown];
	[self.mapButton addTarget:self action:@selector(mapButtonTouchDown) forControlEvents:UIControlEventTouchDown];
	[self.feedbackButton addTarget:self action:@selector(feedbackButtonTouchDown) forControlEvents:UIControlEventTouchDown];
	 */
}

- (void)setRewardTableView
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	int toolBarHeight = self.toolbar.frame.size.height;
	int tableViewHeight = screenHeight - toolBarHeight;
	
	self.rewardTableView = [[UITableView alloc]
							  initWithFrame:CGRectMake(0, toolBarHeight, screenWidth, tableViewHeight)
							  style:UITableViewStylePlain];
	
    [self.rewardTableView setDataSource:self];
    [self.rewardTableView setDelegate:self];
    [self.view addSubview:self.rewardTableView];
	
	self.rewardTableView.tableHeaderView = self.headerView;
	
	self.tableViewController = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.tableViewController];
	
	self.tableViewController.refreshControl = [[UIRefreshControl alloc]init];
	[self.tableViewController.refreshControl addTarget:self
												action:@selector(refreshStoreObject)
									  forControlEvents:UIControlEventValueChanged];
	self.tableViewController.tableView = self.rewardTableView;
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
	
	if (punchCount >= rewardPunches)
	{
		NSString *str1 = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];
		NSString *message = [[reward objectForKey:@"description"] stringByAppendingFormat:@"\n\n%@", str1];
		
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[reward objectForKey:@"reward_name"]
														 andMessage:message];
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
							//nothing
						}];
						[confirmDialogue show];
					}
				}
				else
				{
					NSLog(@"error occurred: %@", error);
					[RepunchUtils showDefaultErrorMessage];
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
		[alertView show];
	}
	else
	{
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Sorry, not enough punches"]
														 andMessage:nil];
            
		[alertView addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:nil];
		[alertView show];
	}
}

- (void)callButtonPressed
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

- (void)mapButtonPressed
{
	//[self.mapButtonView setBackgroundColor:[UIColor clearColor]];
	
    StoreMapViewController *storeMapVC = [[StoreMapViewController alloc] init];
	storeMapVC.storeId = self.storeId;
    [self presentViewController:storeMapVC animated:YES completion:NULL];
}

- (void)feedbackButtonPressed
{
	//[self.feedbackButtonView setBackgroundColor:[UIColor clearColor]];
	
	if(!patronStoreExists) //temp
		return;
	
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.messageType = @"feedback"; //TODO: make this enum
	composeVC.storeId = self.storeId;
	[self presentViewController:composeVC animated:YES completion:NULL];
}

- (void)addStore
{
	[self.addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[self.addToMyPlacesButton setEnabled:FALSE];
	
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
			[self alertParentViewController:TRUE];
		}
		else
		{
			NSLog(@"add_patronStore error: %@", error);
			[self.addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
			[RepunchUtils showDefaultErrorMessage];
		}
	}];
}

- (IBAction)deleteStore:(id)sender
{
	SIAlertView *warningView = [[SIAlertView alloc] initWithTitle:@"Remove from My Places" andMessage:@"WARNING: You will lose all your punches!"];
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

- (void) performDelete
{
	[self.addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[self.addToMyPlacesButton setEnabled:FALSE];
	
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
			 [self alertParentViewController:TRUE];
		 }
		 else
		 {
			 NSLog(@"delete_patronStore error: %@", error);
			 NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
			 [self.addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
			 [RepunchUtils showDefaultErrorMessage];
		 }
	 }];
}

- (void)gift
{
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
		[self presentViewController:facebookFriendsVC animated:YES completion:NULL];
	}
}

- (void) refreshStoreObject
{
	PFQuery *query = [PFQuery queryWithClassName:@"Store"];
	[query getObjectInBackgroundWithId:self.storeId block:^(PFObject *result, NSError *error)
	{
		if(!error)
		{
			[sharedData addStore:result];
			store = result;
			[self setStoreInformation];
			[self setRewardTableView];
		}
		else
		{
			NSLog(@"error fetching Store: %@", error);
			[RepunchUtils showDefaultErrorMessage];
		}
	}];
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
	
	[self presentViewController:composeVC animated:YES completion:nil];
}

- (void)alertParentViewController:(BOOL)isAddRemove
{
	[self.delegate updateTableViewFromStore:self forStoreId:self.storeId andAddRemove:isAddRemove];
}

- (IBAction)closeView:(id)sender
{	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
