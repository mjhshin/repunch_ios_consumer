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

#import "RPCustomAlertController.h"

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
	
	[[NSBundle mainBundle] loadNibNamed:@"StoreTableViewHeaderView" owner:self options:nil];
	[[NSBundle mainBundle] loadNibNamed:@"StoreSectionHeaderView" owner:self options:nil];
	[[NSBundle mainBundle] loadNibNamed:@"StoreSectionHeaderViewAdd" owner:self options:nil];
	
	deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_delete"]
													style:UIBarButtonItemStyleBordered
												   target:self
												   action:@selector(showDeleteStoreDialog)];
	
	addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_add_store"]
													style:UIBarButtonItemStylePlain
												   target:self
												   action:@selector(addStore)];
	
	self.tableView.dataSource = self;
    self.tableView.delegate = self;
	
	[self setStoreInformation];
	[self setupTableViewHeader];
	[self checkPatronStore];
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
		self.chainFeedbackButton.hidden = YES;
		self.storeAddress.text = storeLocation.formattedAddress;
		[self setStoreHours];
	}
    else {
		self.chainFeedbackButton.hidden = NO;
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
						[self.storeImage setImageWithAnimation:downloadedImage];
						[sharedData addCoverImage:downloadedImage forKey:store.objectId];
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
						UIImage *scaledImage = [RepunchUtils imageScaledForThumbnail:downloadedImage];
						[self.storeImage setImageWithAnimation:scaledImage];
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

- (void)setupTableViewHeader
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
	headerFrame.size.height = 345.0f + self.storeInfoViewHeightConstraint.constant;
	self.headerView.frame = headerFrame;
	
	[self.contentView setNeedsLayout];
	[self.contentView layoutIfNeeded];
	
	self.tableView.tableHeaderView = self.headerView;
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
    return [StoreTableViewCell height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return patronStoreExists ? self.sectionHeaderView.frame.size.height : self.sectionHeaderViewAdd.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return store.rewards.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(patronStoreExists) {
		self.punchCountLabel.text = [NSString stringWithFormat:@"%i", punchCount];
		self.punchStaticLabel.text = (punchCount == 1) ? @"Punch": @"Punches";
		
		return self.sectionHeaderView;
	}
	else {
		return self.sectionHeaderViewAdd;
	}
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreTableViewCell reuseIdentifier]];
	if (cell == nil) {
        cell = [StoreTableViewCell cell];
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
	else if(punchCount >= rewardPunches) {
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
	
	//NSString *punches = [NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches];

    __weak typeof (self) weakSelf = self;

        [RPCustomAlertController showRedeemAlertWithTitle:rewardName
												  punches:rewardPunches
												 andBlock:^(RPCustomAlertActionButton buttonType, id anObject) {

            if (buttonType == RedeemButton) {
                if( ![RepunchUtils isConnectionAvailable] ) {
                    [RepunchUtils showDefaultDropdownView:weakSelf.view];
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

                [PFCloud callFunctionInBackground:@"request_redeem" withParameters:functionArguments block:^(NSString *success, NSError *error) {

                    if (!error) {
                        if ([success isEqualToString:@"pending"]) {
                            NSLog(@"function call is: %@", success);
                            [RepunchUtils showDialogWithTitle:@"Pending"
                                                  withMessage:@"You can only request one reward at a time. Please wait for your reward to be approved."];
                        }
                        else {
                            NSLog(@"function call is: %@", success);
                            [RepunchUtils showDialogWithTitle:@"Waiting for confirmation"
                                                  withMessage:@"Please wait for your reward to be approved"];
                        }
                    }
                    else {
                        NSLog(@"error occurred: %@", error);
                        [RepunchUtils showConnectionErrorDialog];
                    }
                }];
                
            }
            else if (buttonType == GiftButton) {
                [weakSelf gift];
            }
            
        }];
}

- (IBAction)callButtonAction:(id)sender
{
	NSString *urlString = [@"telprompt://" stringByAppendingString:storeLocation.phone_number]; //TODO: must remove parantheses for URL to work!!
	NSURL *url = [NSURL URLWithString:urlString];
	//NSURL *url = [NSURL URLWithString:@"telprompt://123-456-7890"];

	if( [[UIApplication sharedApplication] canOpenURL:url] ) {
		[[UIApplication sharedApplication] openURL:url];
	}
	else {
		[RepunchUtils showDialogWithTitle:@"This device does not support phone calls" withMessage:nil];
	}
}

- (IBAction)mapButtonAction:(id)sender
{
	CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(storeLocation.coordinates.latitude,
																	storeLocation.coordinates.longitude);
	
	Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates
                                                       addressDictionary:nil];
		
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = store.store_name;
        
        // Set the directions mode to "Driving"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
		
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
		[MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
					   launchOptions:launchOptions];
	}
}

- (IBAction)feedbackButtonAction:(id)sender
{
    [RPCustomAlertController showCreateMessageAlertWithRecepient:store.store_name andBlock:^(RPCustomAlertActionButton buttonType, id anObject) {

        if (buttonType == SendButton) {
            NSLog(@"%@", anObject);


            NSDictionary *inputsArgs = @{@"patron_id": patron.objectId,
                                        @"store_id": store.objectId,
                                        @"body": anObject,
                                        @"sender_name": patron.full_name,
                                        @"subject": @"Feedback"};


            [PFCloud callFunctionInBackground:@"send_feedback" withParameters:inputsArgs block:^(NSString *result, NSError *error){

                if (!error) {
                    [RepunchUtils showDialogWithTitle:store.store_name withMessage:@"Thanks for your feedback!"];
                    NSLog(@"send_feedback result: %@", result);
                }
                else {
                    [RepunchUtils showDialogWithTitle:@"Send Failed" withMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
                    NSLog(@"send_feedback error: %@", error);
                }
            }];
        }
    }];


/*
    // Demo For Gift
    [RPCustomAlertController showCreateGiftMessageAlertWithRecepient:@"Sime Title" rewardTitle:@"Some Reward" andBlock:^(RPCustomAlertActionButton buttonType, id anObject) {

        if (buttonType == SendButton) {
            NSLog(@"%@", anObject);
        }
    }];
 */


}

- (IBAction)saveStoreButtonAction:(id)sender
{
	[self addStore];
}

- (IBAction)storeInfoGestureAction:(UITapGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded)
	{
		if(self.storeLocationId == nil) {
			LocationsViewController *locationsVC = [[LocationsViewController alloc] init];
			locationsVC.storeId = self.storeId;
			[self.navigationController pushViewController:locationsVC animated:YES];
		}
		else {
			LocationDetailsViewController *locationDetailsVC = [[LocationDetailsViewController alloc] init];
			locationDetailsVC.storeLocationId = self.storeLocationId;
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

	self.saveStoreButton.enabled = NO;
	addButton.enabled = NO;
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
									patron.objectId,		@"patron_id",
									store.objectId,			@"store_id",
									nil];
	
	[PFCloud callFunctionInBackground: @"add_patronstore"
					   withParameters:inputArgs
								block:^(RPPatronStore *result, NSError *error) {
									
		self.saveStoreButton.enabled = YES;
		addButton.enabled = YES;
		
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
			[RepunchUtils showConnectionErrorDialog];
		}
	}];
}

- (void)showDeleteStoreDialog
{
    __weak typeof(self) weakSelf = self;
    [RPCustomAlertController showDeleteMyPlaceAlertWithBlock:^(RPCustomAlertActionButton buttonType, id anObject) {

        if (buttonType == DeleteButton) {
            [weakSelf deleteStore];
        }
    }];
}

- (void)deleteStore
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	deleteButton.enabled = NO;
	
	NSDictionary *inputArgs = [NSDictionary dictionaryWithObjectsAndKeys:
							   patronStore.objectId,	@"patron_store_id",
							   patron.objectId,			@"patron_id",
							   store.objectId,			@"store_id",
							   nil];
	
	[PFCloud callFunctionInBackground: @"delete_patronstore"
					   withParameters:inputArgs
								block:^(NSString *result, NSError *error) {
		 deleteButton.enabled = YES;
		 
		 if(!error) {
			 [sharedData deletePatronStore:self.storeId];
			 [self checkPatronStore];
			 [self.tableView reloadData];
         
			 NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:self.storeId, @"store_id", nil];
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddOrRemoveStore" object:self userInfo:args];
		 }
		 else {
			 NSLog(@"delete_patronStore error: %@", error);
			 [RepunchUtils showConnectionErrorDialog];
		 }
	 }];
}

- (void)refreshPatronStoreObject
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if(patronStoreExists)
	{
		PFQuery *query = [RPPatronStore query];
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
				 [self setupTableViewHeader];
				 [self checkPatronStore];
				 
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
				 [self setupTableViewHeader];
			 }
			 else
			 {
				 NSLog(@"error fetching Store: %@", error);
				 [RepunchUtils showConnectionErrorDialog];
			 }
		 }];
	}
}

- (void)gift
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		[RepunchUtils showDefaultDropdownView:self.view];
		return;
	}
	
	if( ![PFFacebookUtils isLinkedWithUser:[RPUser currentUser]] )
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
