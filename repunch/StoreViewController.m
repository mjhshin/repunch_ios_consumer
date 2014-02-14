//
//  StoreViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreViewController.h"
#import "LocationsViewController.h"
#import "LocationDetailsViewController.h"
#import "RPStore.h"

@implementation StoreViewController
{
	DataManager *sharedData;
	RPStore *store;
	RPStoreLocation *storeLocation;
	RPPatron *patron;
	RPPatronStore *patronStore;
	BOOL patronStoreExists;
	BOOL navigationBarIsOpaque;
    NSInteger punchCount;
	id selectedReward;
	UIBarButtonItem *deleteButton;
	UIBarButtonItem *addButton;
    NSMutableArray *timers;
	UIButton *addToMyPlacesButton;
	CGFloat transitionScrollOffset;
	CGFloat lastContentOffset;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	transitionScrollOffset = self.storeImage.frame.size.height - self.storeName.frame.size.height - 84.0f; //32 is half nav bar height
	self.automaticallyAdjustsScrollViewInsets = NO;
	navigationBarIsOpaque = NO;
	
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
	patron = [sharedData patron];
	store = [sharedData getStore:self.storeId];
	
	if(self.storeLocationId != nil) {
		storeLocation = [sharedData getStoreLocation:self.storeLocationId];
	}
	else if(store.store_locations.count == 1) {
		storeLocation = store.store_locations[0];
		self.storeLocationId = storeLocation.objectId;
	}
	
	[[NSBundle mainBundle] loadNibNamed:@"RewardTableViewHeaderView" owner:self options:nil];
	[[NSBundle mainBundle] loadNibNamed:@"StoreSectionHeaderView" owner:self options:nil];
	
	deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_delete"]
													style:UIBarButtonItemStyleBordered
												   target:self
												   action:@selector(deleteStore)];
	
	addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_add_store"]
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(addStore)];
	
	[self setStoreInformation];
	[self checkPatronStore];
	[self setRewardTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(self.tableView.contentOffset.y < transitionScrollOffset + 5.0f) { // 5 is buffer used in scrollViewDidScroll
		[self setTranslucentNavigationBar];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(!navigationBarIsOpaque) {
		[RepunchUtils setupNavigationController:self.navigationController];
	}
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStoreInformation
{
	self.storeName.text = store.store_name;
	
	CAGradientLayer *bgLayer = [RepunchUtils blackGradient];
	bgLayer.frame = self.storeNameBackground.bounds;
	[self.storeNameBackground.layer insertSublayer:bgLayer atIndex:0];
    
    [self.storeAddress setPreferredMaxLayoutWidth:260];
    [self.storeHours setPreferredMaxLayoutWidth:230];
	
	if(self.storeLocationId != nil) {
		self.storeAddress.text = storeLocation.formattedAddress;
		[self setStoreHours];
	}
    else {
		self.storeAddress.text = @"Multiple Locations";
		self.storeHours.hidden = YES;
		self.storeHoursOpen.hidden = YES;
	}
	
	[self setStoreImage];
}

- (void)setStoreImage
{
	if ( !IS_NIL(store.cover_image) ) {
		self.storeImage.contentMode = UIViewContentModeScaleAspectFill;
		
		UIImage *coverImage = [sharedData getCoverImage:self.storeId];
		
		if(coverImage != nil) {
			self.storeImage.image = coverImage;
		}
		else {
			self.storeImage.image = [UIImage imageNamed:@"placeholder_cover_image"];
			
			[store.cover_image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				if (!error) {
					
					UIImage *downloadedImage = [UIImage imageWithData:data];
					if(downloadedImage) {
						self.storeImage.image = downloadedImage;
						[sharedData addThumbnailImage:downloadedImage forKey:store.objectId];
					}
				}
				else {
					NSLog(@"image download failed");
				}
			}];
		}
	}
	else if( !IS_NIL(store.thumbnail_image) ) {
		self.storeImage.contentMode = UIViewContentModeCenter;
		
		UIImage *thumbnailImage = [sharedData getThumbnailImage:self.storeId];
		
		if(thumbnailImage != nil) {
			self.storeImage.image = [RepunchUtils imageScaledForThumbnail:thumbnailImage];
		}
		else {
			self.storeImage.image = [UIImage imageNamed:@"placeholder_thumbnail_image"];
			
			[store.thumbnail_image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				if (!error) {
					
					UIImage *downloadedImage = [UIImage imageWithData:data];
					if(downloadedImage) {
						self.storeImage.image = [RepunchUtils imageScaledForThumbnail:downloadedImage];
						[sharedData addThumbnailImage:downloadedImage forKey:store.objectId];
					}
				}
				else {
					NSLog(@"image download failed");
				}
			}];
		}
	}
	else {
		self.storeImage.contentMode = UIViewContentModeScaleAspectFill;
		
		//set placeholder cover image
	}
}

- (void)adjustHeaderBasedOnContent
{
	// layout after setting labels' text
	[self.storeInfoView setNeedsLayout];
	[self.storeInfoView layoutIfNeeded];
	
	// adjust storeInfoView's height constraint
	CGRect storeHoursFrame = self.storeHours.frame;
	self.storeInfoViewHeightConstraint.constant = storeHoursFrame.origin.y + storeHoursFrame.size.height;
	
	if( !self.storeHours.hidden ) { // TODO: fix
		self.storeInfoViewHeightConstraint.constant += 10.0f;
	}
		
	// adjust height of headerView frame
	CGRect headerFrame = self.headerView.frame;
	headerFrame.size.height = 350.0f + self.storeInfoViewHeightConstraint.constant;
	self.headerView.frame = headerFrame;
}

- (void)checkPatronStore
{
    patronStore = [sharedData getPatronStore:self.storeId];
    patronStoreExists = (patronStore != nil);
	
	if(patronStoreExists) {
		punchCount = patronStore.punch_count;
		
		RPFacebookPost *facebookPost = patronStore.FacebookPost;
		if( !IS_NIL(facebookPost) )
		{
			[FacebookPost presentDialog:self.storeId withRewardTitle:facebookPost.reward];
		}
	}
	else {
		punchCount = 0;
	}
	
	[self setStoreButtons];
    [self.tableView reloadData];
}

#pragma mark - Store Hours & header size fixer
- (void)setStoreHours
{
    RPStoreHours *hours = storeLocation.hoursManager;
    
    if (hours.isOpenAlways) {
        self.storeHours.hidden = NO;
        self.storeHoursOpen.hidden = NO;
        
        self.storeHoursOpen.text = NSLocalizedString(@"Open", nil);
        self.storeHoursOpen.textColor = [UIColor colorWithRed:0.0 green:(204/255.0) blue:0.0 alpha:1.0];
        self.storeHours.text = @"Open 24/7";
    }
    else if(hours) {
        self.storeHours.hidden = NO;
        self.storeHoursOpen.hidden = NO;
        self.storeHours.text = @"";
        
        NSArray *repunchDates = [hours hoursForToday];
        
        NSDateFormatter *outFormat = [[NSDateFormatter alloc] init];
        outFormat.dateFormat = @"h:mm a";
        
        NSMutableString *fullString = [[NSMutableString alloc] initWithString:@"Hours Today:"];
        
        for (NSDictionary *hours in repunchDates) {
            
            NSDate *open = hours[kOpenTime];
            NSDate *close = hours[kCloseTime];
            
            NSString *openString = [outFormat stringFromDate:open];
            NSString *closeString = [outFormat stringFromDate:close];
            
            [fullString appendString:[NSString stringWithFormat:@" %@ - %@,", openString, closeString]];
        }
		[fullString deleteCharactersInRange:NSMakeRange(fullString.length-1, 1)]; //remove final comma
        
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
        self.storeHours.hidden = YES;
        self.storeHoursOpen.hidden = YES;
    }
}

- (void)setStoreButtons
{
	if(!patronStoreExists) {
		self.navigationItem.rightBarButtonItem = addButton;
		
		self.feedbackButton.enabled = NO;
	}
	else {
		self.navigationItem.rightBarButtonItem = deleteButton;
		
		if(patronStore.all_time_punches > 0) {
			self.feedbackButton.enabled = YES;
		}
	}
}

- (void)setRewardTableView
{
	[self adjustHeaderBasedOnContent];
	
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
	self.tableView.tableHeaderView = self.headerView;
}

- (void)setOpaqueNavigationBar
{
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.4f];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setType:kCATransitionFade];
	
	[self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4f];
	
	self.navigationItem.title = store.store_name;
	[RepunchUtils setupNavigationController:self.navigationController];
	navigationBarIsOpaque = YES;
	self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
	
	[UIView commitAnimations];
}

- (void)setTranslucentNavigationBar
{
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.25f];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setType:kCATransitionFade];
	
	[self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25f];
	
	self.navigationItem.title = @"";
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black_alpha_gradient"] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];
	navigationBarIsOpaque = NO;
	self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	
	[UIView commitAnimations];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat buffer = 5.0f;
	
	if(scrollView.contentOffset.y > transitionScrollOffset)
	{
		if(!navigationBarIsOpaque) {
			[self setOpaqueNavigationBar];
		}
	}
	else if(scrollView.contentOffset.y < transitionScrollOffset + buffer)
	{
		if(navigationBarIsOpaque) {
			[self setTranslucentNavigationBar];
		}
		
		if(scrollView.contentOffset.y <= 0) { //expand image
			self.storeImageHeightConstraint.constant = 240.0f - scrollView.contentOffset.y; //240 is height of image
		}
	}
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 140;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return store.rewards.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(patronStoreExists) {
		//self.saveButton.hidden = YES;
	
		self.punchCountLabel.text = [NSString stringWithFormat:@"%i", punchCount];
		self.punchStaticLabel.text = (punchCount == 1) ? @"Punch": @"Punches";
	}
	else {
		//self.saveButton.hidden = NO;
	}

	return self.sectionHeaderView;
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RewardTableViewCell reuseIdentifier]];
	if (cell == nil) {
        cell = [RewardTableViewCell cell];
    }
	
	id reward = store.rewards[indexPath.row];
    
    cell.rewardTitle.text = reward[@"reward_name"];
    cell.rewardDescription.text = reward[@"description"];
	
    NSInteger rewardPunches = [reward[@"punches"] integerValue];
    cell.rewardPunches.text = [NSString stringWithFormat:@"%i", rewardPunches];
	cell.rewardPunchesStatic.text = (rewardPunches == 1) ? @"Punch" : @"Punches";
	
	if(!patronStoreExists) {
		[cell setPatronStoreNotAdded];
	}
	else if(punchCount >= rewardPunches){
		[cell setRewardUnlocked];
	}
	else {
		[cell setRewardLocked];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	id reward = store.rewards[indexPath.row];
	selectedReward = reward;

	NSInteger rewardPunches = [reward[@"punches"] integerValue];
	NSInteger rewardId = [reward[@"reward_id"] integerValue];
	NSString *rewardPunchesString = [NSString stringWithFormat:@"%i", rewardPunches];
	NSString *rewardIdString = [NSString stringWithFormat:@"%i", rewardId];
	NSString *rewardName = reward[@"reward_name"];
	
	NSString *str1 = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];
	NSString *message = [str1 stringByAppendingFormat:@"\n\n%@", reward[@"description"]];

	SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:reward[@"reward_name"]
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
													patron.full_name,			@"name",
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
    /*NSString *phoneNumber = [store.phone_number stringByReplacingOccurrencesOfString:@"[^0-9]"
															  withString:@""
																 options:NSRegularExpressionSearch
																   range:NSMakeRange(0, store.phone_number.length)];*/
	
	NSString * phoneNumber = @"(123) 456-7890";
	
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];
}

- (IBAction)mapButtonAction:(id)sender
{
	StoreMapViewController *storeMapVC = [[StoreMapViewController alloc] init];
	storeMapVC.storeLocation = storeLocation;
    [self.navigationController pushViewController:storeMapVC animated:YES];
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

- (IBAction)storeInfoGestureAction:(UITapGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded)
	{
		if(self.storeLocationId == nil) {
			LocationsViewController *locationsVC = [[LocationsViewController alloc] init];
			locationsVC.store = store;
			[self.navigationController pushViewController:locationsVC animated:YES];
		}
		else {
			LocationDetailsViewController *locationDetailsVC = [[LocationDetailsViewController alloc] init];
			locationDetailsVC.storeLocation = storeLocation;
			[self.navigationController pushViewController:locationDetailsVC animated:YES];
		}
	}
}

- (void)addStore
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	[addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[addToMyPlacesButton setEnabled:NO];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = addToMyPlacesButton.bounds;
	[addToMyPlacesButton addSubview:spinner];
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
			[sharedData addPatronStore:(RPPatronStore *)result forKey:self.storeId];
			[self checkPatronStore];
			
			NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:self.storeId, @"store_id", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:args];
		}
		else
		{
			NSLog(@"add_patronStore error: %@", error);
			[addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
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
	
	[addToMyPlacesButton setTitle:@"" forState:UIControlStateNormal];
	[addToMyPlacesButton setEnabled:NO];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = addToMyPlacesButton.bounds;
	[addToMyPlacesButton addSubview:spinner];
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
			 [self.tableView reloadData];
         
			 NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:self.storeId, @"store_id", nil];
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:args];
		 }
		 else
		 {
			 NSLog(@"delete_patronStore error: %@", error);
			 NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
			 [addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
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
	
	if( patron.facebook_id == nil)
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
		//[self.tableViewController.refreshControl endRefreshing];
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(patronStoreExists)
	{
		PFQuery *query = [PFQuery queryWithClassName:[RPPatronStore parseClassName]];
		[query includeKey:@"Store"];
        [query includeKey:@"Store.store_locations"];
		[query includeKey:@"FacebookPost"];
		[query getObjectInBackgroundWithId:patronStore.objectId block:^(PFObject *result, NSError *error)
		 {
			 if(!error)
			 {
				 patronStore = (RPPatronStore *)result;
				 store = patronStore.Store;
				 [sharedData addPatronStore:patronStore forKey:self.storeId];
				 [sharedData addStore:store];
				 
				 [self setStoreInformation];
				 [self checkPatronStore];
				 [self setRewardTableView];
				 
				 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:nil];
			 }
			 else
			 {
				 NSLog(@"error fetching PatronStore: %@", error);
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
	composeVC.giftTitle = selectedReward[@"reward_name"];
	composeVC.giftDescription = selectedReward[@"description"];
	composeVC.giftPunches = [selectedReward[@"punches"] intValue];
	composeVC.recepientName = name;
	
	UINavigationController *composeNavController = [[UINavigationController alloc] initWithRootViewController:composeVC];
	[RepunchUtils setupNavigationController:composeNavController];
	
	[self presentViewController:composeNavController animated:YES completion:nil];
}

@end
