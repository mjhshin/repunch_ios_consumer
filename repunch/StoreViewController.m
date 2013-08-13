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
    
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patron = [sharedData patron];
	self.rewardArray = [NSMutableArray array];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = self.toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	[[NSBundle mainBundle] loadNibNamed:@"StoreHeaderView" owner:self options:nil];
	
	CAGradientLayer *bgLayer2 = [GradientBackground orangeGradient];
	bgLayer2.frame = self.addToMyPlacesButton.bounds;
	[self.addToMyPlacesButton.layer insertSublayer:bgLayer2 atIndex:0];
	
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
	} else {
		punchCount = 0;
	}
	
	[self setStoreButtons];
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

	
	self.storeName.text = name;
	
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
				 }
			 }];
		} else {
			self.storeImage.image = storeImage;
		}
	} else {
		self.storeImage.image = [UIImage imageNamed:@"listview_placeholder.png"];
	}
}

- (void)setStoreButtons
{	
	if(!patronStoreExists)
	{
		[self.addToMyPlacesButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
		[self.addToMyPlacesButton setEnabled:TRUE];
		[self.addToMyPlacesButton addTarget:self
									 action:@selector(addStore)
						   forControlEvents:UIControlEventTouchUpInside];
		[self.deleteButton setHidden:TRUE];
	}
	else
	{
		NSString *buttonText = [NSString stringWithFormat:@"%i %@", punchCount, (punchCount == 1) ? @"Punch": @"Punches"];
		[self.addToMyPlacesButton setTitle:buttonText forState:UIControlStateNormal];
		[self.addToMyPlacesButton setEnabled:FALSE];
		[self.deleteButton setHidden:FALSE];
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
}

- (NSString *)getHoursString
{
	/*
    NSDateFormatter *formatter_out = [[NSDateFormatter alloc] init];
    [formatter_out setDateFormat:@"h:mm a"];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    if (weekday>1)
        weekday--;
    else
        weekday=7;
    
    bool open = false;
    NSString *hourstodaystring = @"";
    NSArray *hoursArray = [[NSArray alloc] initWithArray:[[_storeObject valueForKey:@"hours"] allObjects]];
    for(NSDictionary *hours in hoursArray) {
        if ([[hours valueForKey:@"day"] integerValue] == weekday) {
            
            NSString *openHour = [[hours valueForKey:@"open_time"] substringToIndex:2];
            NSString *openMinute = [[hours valueForKey:@"open_time"]  substringFromIndex:2];
            
            NSString *closeHour = [[hours valueForKey:@"close_time"]  substringToIndex:2];
            NSString *closeMinute = [[hours valueForKey:@"close_time"]  substringFromIndex:2];
            
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
            [components setHour:[openHour integerValue]];
            [components setMinute:[openMinute integerValue]];
            
            NSDate *openDate = [calendar dateFromComponents:components];
            
            [components setHour:[closeHour integerValue]];
            [components setMinute:[closeMinute integerValue]];
            NSDate *closeDate = [calendar dateFromComponents:components];
            
            hourstodaystring = [NSString stringWithFormat:@"%@ - %@",[formatter_out stringFromDate:openDate],[formatter_out stringFromDate:closeDate]];
            
            open = (([now compare:openDate] != NSOrderedAscending) && ([now compare:closeDate] != NSOrderedDescending));
        }
    }
    
    if (![hourstodaystring isEqualToString:@""]){
        hourstodaystring = @"Unavailable";
        _storeOpen.text = @"";
    } else{
        _storeOpen.text = (open)?@"Open":@"Closed";
        UIColor *openColor = [UIColor colorWithRed:104/255.f green:136/255.f blue:13/255.f alpha:1];
        UIColor *closedColor = [UIColor blackColor];
        _storeOpen.textColor = (open ? openColor : closedColor);

    }

    return hourstodaystring;
    */
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
    
    if (!patronStoreExists) {
        [cell setUserInteractionEnabled:NO];
    }
	
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

	int rewardPunches = [[reward objectForKey:@"punches"] intValue];
	int rewardId = [[reward objectForKey:@"reward_id"] intValue];
	NSString *rewardPunchesString = [NSString stringWithFormat:@"%d", rewardPunches];
	NSString *rewardIdString = [NSString stringWithFormat:@"%d", rewardId];
	NSString *rewardName = [reward objectForKey:@"reward_name"];
	NSString *patronName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
	
	if (punchCount >= rewardPunches)
	{
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[reward objectForKey:@"reward_name"]
														 andMessage:[NSString stringWithFormat:(rewardPunches == 1 ? @"%i Punch" :  @"%i Punches"), rewardPunches]];
		[alertView addButtonWithTitle:@"Redeem"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert)
		{
			NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:
													[store objectId],			@"store_id",
													[patronStore objectId],		@"patron_store_id",
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
						[confirmDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
							//nothing
						}];
						[confirmDialogue show];
					}
					else
					{
						NSLog(@"function call is: %@", success);
						SIAlertView *confirmDialogue = [[SIAlertView alloc] initWithTitle:@"Waiting for confirmation" andMessage:@"Please wait for your reward to be validated"];
						[confirmDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
							//nothing
						}];
						[confirmDialogue show];
					}
				}
				else
				{
					NSLog(@"error occurred: %@", error);
					SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error" andMessage:@"Please wait for your reward to be validated"];
					[errorDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
						//nothing
					}];
					[errorDialogue show];
				}
			}];
		}];

		[alertView addButtonWithTitle:@"Gift"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert)
		 {
			 /*
			 FacebookFriendsViewController *friendsVC = [[FacebookFriendsViewController alloc] init];
                                      
			 NSDictionary *giftDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[store objectId], @"store_id",
											 [patronStore objectId], @"patron_store_id",
											 [localUser patronId], @"user_id",
											 [localUser fullName], @"sender_name",
											 [currentCellReward reward_name], @"gift_title",
											 [currentCellReward reward_description], @"gift_description",
											 [currentCellReward punches] ,@"gift_punches",
											 nil];
                                      
                                      
			 friendsVC.giftParametersDict = giftDictionary;
                                      
			 [self presentViewController:friendsVC animated:YES completion:nil];
			  */
		 }];
            
		[alertView addButtonWithTitle:@"Cancel"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
								  [alert dismissAnimated:TRUE];
							  }];
		alertView.transitionStyle = SIAlertViewTransitionStyleSlideFromBottom;
		[alertView show];
	}
	else
	{
		SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Sorry, not enough punches"]
														 andMessage:nil];
            
		[alertView addButtonWithTitle:@"OK"
								 type:SIAlertViewButtonTypeDefault
							  handler:^(SIAlertView *alert) {
								  [alert dismissAnimated:TRUE];
		}];
		[alertView show];
	}
}

- (void)publishButtonActionWithParameters:(NSDictionary*)userInfo
{
	/*
    PFQuery *getStore = [PFQuery queryWithClassName:@"Store"];
    [getStore getObjectInBackgroundWithId:[userInfo valueForKey:@"store_id"] block:^(PFObject *fetchedStore, NSError *error) {
        NSString *picURL = [[fetchedStore objectForKey:@"store_avatar"] url];
        
        // Put together the dialog parameters
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"Just redeemed %@ with Repunch", [userInfo valueForKey:@"reward_title"]], @"name",
         [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"store_name"]], @"caption",
         picURL, @"picture",
         nil];
        
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                         NSDictionary *functionParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[userInfo valueForKey:@"patron_store_id"], @"patron_store_id", @"false", @"accept", nil];
                         [PFCloud callFunctionInBackground:@"facebook_post" withParameters:functionParameters block:^(id object, NSError *error) {
                             if (!error){
                                 NSLog(@"facebook function call is :%@", object);
                             }
                             else {
                                 NSLog(@"error is %@", error);
                             }
                         }];

                     } else {
                         // User clicked the Share button
                         NSString *msg = [NSString stringWithFormat:
                                          @"Posted the status!"];
                         NSLog(@"%@", msg);
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Yay! More punches for you!"
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil]
                          show];
                         
                         NSDictionary *functionParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[userInfo valueForKey:@"patron_store_id"], @"patron_store_id", @"true", @"accept", nil];
                         [PFCloud callFunctionInBackground:@"facebook_post" withParameters:functionParameters block:^(id object, NSError *error) {
                             if (!error){
                                 NSLog(@"facebook function call is :%@", object);
                                 
                             }
                             
                             else {
                                 NSLog(@"error is %@", error);
                             }
                         }];
                         
                     }
                 }
             }
         }];
        
        
    }];
    */
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
			 [self alertParentViewController:TRUE];
		 }
		 else
		 {
			 NSLog(@"delete_patronStore error: %@", error);
		 }
	 }];
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
