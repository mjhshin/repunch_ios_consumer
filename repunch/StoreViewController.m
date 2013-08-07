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
    
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patron = [sharedData patron];
	patronStore = [sharedData getPatronStore:_storeId];
    patronStoreExists = (patronStore != [NSNull null]);
	punchCount = [[patronStore objectForKey:@"punch_count"] intValue];
	self.rewardArray = [NSMutableArray init];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[self.toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	[self setStoreInformation];
	[self setStoreButtons];
	[self setRewardTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];
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
	
	_storeName.text = name;
	
	if(crossStreets != nil) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:crossStreets];		
	}
	
	if(neighborhood != nil ) {
		street = [street stringByAppendingString:@"\n"];
		street = [street stringByAppendingString:neighborhood];
	}
	
	street = [street stringByAppendingString:@"\n"];
	street = [street stringByAppendingString:[NSString stringWithFormat:@"%@/%@/%@/%@/%@", city, @", ", state, @" ", zip]];
	
	_storeAddress.text = street;
	
	PFFile *imageFile = [store objectForKey:@"store_avatar"];
	if(imageFile != nil)
	{
		UIImage *storeImage = [sharedData getStoreImage:self.storeId];
		if(storeImage == nil)
		{
			_storePic.image = [UIImage imageNamed:@"listview_placeholder.png"];
			[imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
			 {
				 if (!error) {
					 UIImage *storeImage = [UIImage imageWithData:data];
					 _storePic.image = storeImage;
					 [sharedData addStoreImage:storeImage forKey:self.storeId];
				 }
				 else
				 {
					 NSLog(@"image download failed");
				 }
			 }];
		} else {
			_storePic.image = storeImage;
		}
	} else {
		_storePic.image = [UIImage imageNamed:@"listview_placeholder.png"];
	}
}

- (void)setStoreButtons
{
	//hide feedback button
}

- (void)setRewardTableView
{
	int tableViewHeight = self.view.frame.size.height - 50; //50 is nav bar height
	//int tabBarSize = self.tabBarController.tabBar.frame.size.height;
	self.rewardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, tableViewHeight) style:UITableViewStylePlain];
    [self.rewardTableView setDataSource:self];
    [self.rewardTableView setDelegate:self];
    [self.view addSubview:self.rewardTableView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rewardArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RewardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[RewardTableViewCell reuseIdentifier]];
	if (cell == nil)
    {
        cell = [RewardTableViewCell cell];
    }
    
    cell.rewardTitle.text = [[self.rewardArray objectAtIndex:indexPath.row] valueForKey:@"reward_name"];
    cell.rewardDescription.text = [[self.rewardArray objectAtIndex:indexPath.row] valueForKey:@"reward_description"];
    int rewardPunches = [[[self.rewardArray objectAtIndex:indexPath.row] valueForKey:@"punches"] intValue];
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
	/*
    if (_isSavedStore){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        Reward *currentCellReward = [placeRewardData objectAtIndex:indexPath.row];

        int required = [[currentCellReward punches] intValue];
        if (availablePunches >= required){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@.", [currentCellReward reward_name]] andMessage:[NSString stringWithFormat:@"It'll cost you %@.", [NSString stringWithFormat:(required == 1 ? @"%i Punch" :  @"%i Punches"), required]]];
            
            [alertView addButtonWithTitle:@"Redeem"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_storeObject objectId], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [currentCellReward reward_name], @"title", [currentCellReward objectId], @"reward_id", [currentCellReward punches], @"num_punches",   [localUser fullName], @"name", nil];

                                      [PFCloud callFunctionInBackground:@"request_redeem"
                                                         withParameters:functionArguments
                                                                  block:^(NSString *success, NSError *error) {
                                                                      if (!error) {
                                                                          if ([success isEqualToString:@"pending"]){
                                                                              NSLog(@"function call is :%@", success);
                                                                              SIAlertView *confirmDialogue = [[SIAlertView alloc] initWithTitle:@"Pending" andMessage:@"You already have a pending reward"];
                                                                              [confirmDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                                                                                  //nothing
                                                                              }];
                                                                              [confirmDialogue show];
                                                                          }
                                                                          else {
                                                                              NSLog(@"function call is :%@", success);
                                                                              SIAlertView *confirmDialogue = [[SIAlertView alloc] initWithTitle:@"Waiting for confirmation" andMessage:@"Please wait for your reward to be validated"];
                                                                              [confirmDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                                                                                  //nothing
                                                                              }];
                                                                              [confirmDialogue show];
                                                                          }
                                                                      }
                                                                      else {
                                                                          NSLog(@"error occurred: %@", error);
                                                                          SIAlertView *errorDialogue = [[SIAlertView alloc] initWithTitle:@"Error" andMessage:@"Please wait for your reward to be validated"];
                                                                          [errorDialogue addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                                                                              //nothing
                                                                          }];
                                                                          [errorDialogue show];
                                                                      }
                                                                  }];
                                      NSLog(@"Redeem Clicked");
                                  }];
            [alertView addButtonWithTitle:@"Gift"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      RepunchFriendsViewController *friendsVC = [[RepunchFriendsViewController alloc]init];
                                      friendsVC.modalDelegate = self;
                                      
                                      NSDictionary *giftDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[_storeObject objectId], @"store_id", patronStoreEntity.objectId, @"patron_store_id", [localUser patronId], @"user_id", [localUser fullName], @"sender_name", [currentCellReward reward_name], @"gift_title", [currentCellReward reward_description], @"gift_description", [currentCellReward punches] ,@"gift_punches", nil];
                                      
                                      
                                      friendsVC.giftParametersDict = giftDictionary;
                                      
                                      [self presentViewController:friendsVC animated:YES completion:nil];


                                      
                                      NSLog(@"Gift Clicked");
                                  }];
            
            [alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      //Nothing Happens
                                  }];

            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

            [alertView show];
        }
        else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@.", [[placeRewardData objectAtIndex:indexPath.row] valueForKey:@"reward_name"]] andMessage:[NSString stringWithFormat:@"You don't have %@.", [NSString stringWithFormat:(required == 1 ? @"%i Punch" :  @"%i Punches"), required]]];
            
            [alertView addButtonWithTitle:@"Okay."
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      //Nothing Happens
                                  }];

        }
     }


}

-(void)addOrRemovePlace
{
    UIView *greyedOutView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height - 50)];
    [greyedOutView setBackgroundColor:[UIColor colorWithRed:127/255 green:127/255 blue:127/255 alpha:0.5]];
    [[self view] addSubview:greyedOutView];
    [[self view] bringSubviewToFront:greyedOutView];


    PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
    [patronQuery getObjectInBackgroundWithId:localUser.patronId block:^(PFObject *patronObject, NSError *error) {
        if (!error){
            
            //add store
            if (!_isSavedStore){
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                spinner.center = CGPointMake(160, 260);
                spinner.color = [UIColor blackColor];
                [[self view] addSubview:spinner];
                
                //[spinner startAnimating];
                
                PatronStore *newPatronStoreEntity = [PatronStore MR_createEntity];
                [newPatronStoreEntity setFromPatronObject:patronObject andStoreEntity:_storeObject andUserEntity:localUser andPatronStore:nil];
                [localUser addSaved_storesObject:newPatronStoreEntity];
                [localContext MR_saveToPersistentStoreAndWait];
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Added!" andMessage:[NSString stringWithFormat:@"You've saved %@", [_storeObject valueForKey:@"store_name"]]];
                
                [alertView addButtonWithTitle:@"Okay."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          _isSavedStore = TRUE;
                                          [self viewWillAppear:YES];
                                      }];
                [alertView show];

                NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[patronObject objectId], @"patron_id", [_storeObject objectId], @"store_id", nil];
                
                [PFCloud callFunctionInBackground: @"add_patronstore"
                                   withParameters:functionArguments block:^(PFObject *patronStore, NSError *error) {
                                       //[spinner stopAnimating];
                                       [greyedOutView removeFromSuperview];
                                       newPatronStoreEntity.objectId = [patronStore objectId];
                                   }];


            }
            
            //remove store
            else{
                SIAlertView *warningView = [[SIAlertView alloc] initWithTitle:@"Warning!" andMessage:[NSString stringWithFormat:@"Are you sure you want to remove %@? You will lose all your punches", [_storeObject valueForKey:@"store_name"]]];
                [warningView addButtonWithTitle:@"Cancel"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          //[greyedOutView removeFromSuperview];
                                          
                                      }];

                
                [warningView addButtonWithTitle:@"Okay"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                          
                                          spinner.center = CGPointMake(160, 260);
                                          spinner.color = [UIColor blackColor];
                                          [[self view] addSubview:spinner];

                                          [spinner startAnimating];
                                          
                                          NSDictionary *cloudFunctionParameters = [[NSDictionary alloc] initWithObjectsAndKeys:patronStoreEntity.objectId, @"patron_store_id", localUser.patronId, @"patron_id", _storeObject.objectId, @"store_id", nil];
                                          
                                          
                                          [PFCloud callFunctionInBackground:@"delete_patronstore" withParameters:cloudFunctionParameters block:^(id object, NSError *error) {
                                              //get patronStore and delete it
                                              PatronStore *storeToDelete = [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, _storeObject.objectId]];
                                              [localContext deleteObject:storeToDelete];

                                          }];
                                          
                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Removed!" andMessage:[NSString stringWithFormat:@"You've removed %@", [_storeObject valueForKey:@"store_name"]]];

                                          
                                          [alertView addButtonWithTitle:@"Okay."
                                                                   type:SIAlertViewButtonTypeDefault
                                                                handler:^(SIAlertView *alert) {
                                                                    [[self modalDelegate] didDismissPresentedViewController];
                                                                }];
                                          [alertView show];

                                      }];
                [warningView show];

            }
            
        } else NSLog(@"error is %@", error);
    }];

}

- (void)publishButtonActionWithParameters:(NSDictionary*)userInfo
{
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

- (IBAction)callButton:(id)sender
{
    NSString *number = [store objectForKey:@"phone_number"];
    NSString *phoneNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]"
															  withString:@""
																 options:NSRegularExpressionSearch
																   range:NSMakeRange(0, [number length])];
	
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];
}

- (IBAction)mapButton:(id)sender
{
    StoreMapViewController *storeMapVC = [[StoreMapViewController alloc] init];
    [self presentViewController:storeMapVC animated:YES completion:NULL];
}

- (IBAction)feedbackButton:(id)sender
{
	ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
	composeVC.messageType = @"Feedback";
	[self presentViewController:composeVC animated:YES completion:NULL];
}

- (IBAction)addStore:(id)sender
{
    //[self addOrRemovePlace];
}

- (IBAction)deleteStore:(id)sender
{
    //[self addOrRemovePlace];
}

- (IBAction)closeView:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
