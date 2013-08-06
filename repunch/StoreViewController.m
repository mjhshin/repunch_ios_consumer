//
//  StoreViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreViewController.h"
#import "StoreMapViewController.h"
#import "SIAlertView.h"
#import "RewardCell.h"
#import "AppDelegate.h"
#import "ComposeMessageViewController.h"
#import "FacebookFriendsViewController.h"
#import "GradientBackground.h"
#import "DataManager.h"

@implementation StoreViewController
{
	DataManager *sharedData;
    NSMutableArray *placeRewardData;
    StoreMapViewController *placesDetailMapVC;
    int availablePunches;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	sharedData = [DataManager getSharedInstance];
	_store = [sharedData getStore:_storeId];
	_patronStore = [sharedData getPatronStore:_storeId];
    _isSavedStore = (_patronStore != [NSNull null]);
    _scrollView.scrollEnabled = YES;
    
    _storeName.text = [_store valueForKey:@"store_name"];
    //_storePic.image = [UIImage imageWithData:_store.store_avatar];
    _storeStreet.text = [_store valueForKey:@"street"];
	
	/*
	 if ([[_storeObject valueForKey:@"cross_streets"] length]>0) {
	 _storeCrossStreets.text = [_storeObject valueForKey:@"cross_streets"];
	 _storeCrossStreets.hidden = FALSE;
	 [_storeNeighborhood setFrame:CGRectMake(_storeNeighborhood.frame.origin.x, _storeNeighborhood.frame.origin.y  + _storeCrossStreets.frame.size.height-8, _storeNeighborhood.frame.size.width, _storeNeighborhood.frame.size.height)];
	 
	 [_storeCity setFrame:CGRectMake(_storeCity.frame.origin.x, _storeCity.frame.origin.y +  _storeCrossStreets.frame.size.height-8, _storeCity.frame.size.width, _storeCity.frame.size.height)];
	 }
	 if ([[_storeObject valueForKey:@"neighborhood"] length]>0) {
	 _storeNeighborhood.text = [_storeObject valueForKey:@"neighborhood"];
	 _storeNeighborhood.hidden = FALSE;
	 [_storeCity setFrame:CGRectMake(_storeCity.frame.origin.x, _storeCity.frame.origin.y +  _storeNeighborhood.frame.size.height-8, _storeCity.frame.size.width, _storeCity.frame.size.height)];
	 
	 }
	 
	 _storeCity.text = [NSString stringWithFormat:@"%@, %@ %@",[_storeObject valueForKey:@"city"], [_storeObject valueForKey:@"state"], [_storeObject valueForKey:@"zip"]];
	 
	 _storeHours.text = [self getHoursString];
	 
	 placeRewardData = [[[_storeObject mutableSetValueForKey:@"rewards"] allObjects] mutableCopy];
	 NSLog(@"rewards are :%@", [placeRewardData valueForKey:@"reward_name"]);
	 
	 [placeRewardData sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"punches" ascending:YES]]];
	 
	 [_rewardsTable setDataSource:self];
	 [_rewardsTable setDelegate:self];
	 
	 [_scrollView setContentSize:CGSizeMake(320, [self bottomOfLowestContent:[self view]])];
	 
	 _leftoverFBPostExists = FALSE;
	 patronStoreEntity= [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, _storeObject.objectId]];
	 availablePunches = [[patronStoreEntity punch_count] intValue];
*/
    /*
	 if (_isSavedStore || _leftoverFBPostExists) {
	 PFQuery *query = [PFQuery queryWithClassName:@"PatronStore"];
	 [query includeKey:@"FacebookPost"];
	 [query getObjectInBackgroundWithId:patronStoreEntity.objectId block:^(PFObject *fetchedPatronStore, NSError *error) {
	 if ([fetchedPatronStore objectForKey:@"FacebookPost"] == nil) {
	 [self publishButtonActionWithParameters:[[NSDictionary alloc] initWithObjectsAndKeys:[patronStoreEntity store_id], @"store_id", [patronStoreEntity objectId], @"patron_store_id", [_storeObject store_name], @"store_name", [[_patronStoreObject objectForKey:@"FacebookPost"] valueForKey:@"reward"], @"reward_title", nil]];
	 _leftoverFBPostExists = FALSE;
	 _patronStoreObject = fetchedPatronStore;
	 NSLog(@"there is a facebook post!");
	 }
	 }];
	 }*/
}

- (void)viewWillAppear:(BOOL)animated
{
	/*
    [super viewWillAppear:YES];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
    
    [_rewardsTable reloadData];
    
    placeRewardData = [[[_storeObject mutableSetValueForKey:@"rewards"] allObjects] mutableCopy];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"punches"  ascending:YES];
    placeRewardData = [[placeRewardData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];

    patronStoreEntity= [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, _storeObject.objectId]];
    availablePunches = [[patronStoreEntity punch_count] intValue];
    
    if (!_isSavedStore) {
        //[_numPunches setText:@""];
        [_feedbackBtn setImage:[UIImage imageNamed:@"ico-feedback-block"] forState:UIControlStateNormal];
        [_feedbackBtn setHidden:TRUE];
        [_feedbackLbl setHidden:TRUE];
        
        [_callView setFrame:CGRectMake(_callView.frame.origin.x + 43, _callView.frame.origin.y, _callView.frame.size.width, _callView.frame.size.height)];
        [_mapView setFrame:CGRectMake(_mapView.frame.origin.x + 73, _mapView.frame.origin.y, _mapView.frame.size.width, _mapView.frame.size.height)];

    }
    else{
        int punches = [[patronStoreEntity punch_count] intValue];
        [_addPlaceBtn setTitle:[NSString stringWithFormat:@"%d %@", punches, (punches==1)?@"punch":@"punches"] forState:UIControlStateNormal];
        [_addPlaceBtn setUserInteractionEnabled:FALSE];
                
    }
    
    if (!_isSavedStore){
        [_deleteButton setHidden:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"receivedPush"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedOrRemovedStore" object:self];
*/

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];

}

- (CGFloat)bottomOfLowestContent:(UIView*)view
{
    CGFloat lowestPoint = 0.0;
    
    BOOL restoreHorizontal = NO;
    BOOL restoreVertical = NO;
    
    if ([view respondsToSelector:@selector(setShowsHorizontalScrollIndicator:)] && [view respondsToSelector:@selector(setShowsVerticalScrollIndicator:)])
    {
        if ([(UIScrollView*)view showsHorizontalScrollIndicator])
        {
            restoreHorizontal = YES;
            [(UIScrollView*)view setShowsHorizontalScrollIndicator:NO];
        }
        if ([(UIScrollView*)view showsVerticalScrollIndicator])
        {
            restoreVertical = YES;
            [(UIScrollView*)view setShowsVerticalScrollIndicator:NO];
        }
    }
    for (UIView *subView in view.subviews)
    {
        if (!subView.hidden)
        {
            CGFloat maxY = CGRectGetMaxY(subView.frame);
            if (maxY > lowestPoint)
            {
                lowestPoint = maxY;
            }
        }
    }
    if ([view respondsToSelector:@selector(setShowsHorizontalScrollIndicator:)] && [view respondsToSelector:@selector(setShowsVerticalScrollIndicator:)])
    {
        if (restoreHorizontal)
        {
            [(UIScrollView*)view setShowsHorizontalScrollIndicator:YES];
        }
        if (restoreVertical)
        {
            [(UIScrollView*)view setShowsVerticalScrollIndicator:YES];
        }
    }
    
    return lowestPoint;
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [placeRewardData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RewardCell";
    RewardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RewardCell" owner:self options:nil]objectAtIndex:0];
    }
    
    // Configure the cell...
    
    cell.rewardName.text = [[placeRewardData objectAtIndex:indexPath.row] valueForKey:@"reward_name"];
    cell.rewardDescription.text = [[placeRewardData objectAtIndex:indexPath.row] valueForKey:@"reward_description"];
    int required = [[[placeRewardData objectAtIndex:indexPath.row] valueForKey:@"punches"] intValue];
    cell.numberOfPunches.text = [NSString stringWithFormat:(required == 1 ? @"%i Punch" :  @"%i Punches"), required];
    if (availablePunches >= required){
        cell.padlockPic.image = [UIImage imageNamed:@"reward_unlocked"];
    }
    
    if (!_isSavedStore){
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

#pragma mark - Modal Delegate


-(void)closePlaceDetail{
    [[self modalDelegate] didDismissPresentedViewController];
}

#pragma mark - Other methods

-(void)addOrRemovePlace{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
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

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];;
}

- (void)publishButtonActionWithParameters:(NSDictionary*)userInfo{
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

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)callButton:(id)sender
{
	/*
    NSString *number = [_storeObject phone_number];
    NSString *phoneNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]"
															  withString:@""
																 options:NSRegularExpressionSearch
																   range:NSMakeRange(0, [number length])];
	
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];
	 */
}

- (IBAction)mapButton:(id)sender
{
    placesDetailMapVC = [[StoreMapViewController alloc] init];
    //placesDetailMapVC.storeId = [store objectId];
    [self presentViewController:placesDetailMapVC animated:YES completion:NULL];
}

- (IBAction)feedbackButton:(id)sender
{
    if (!_isSavedStore){
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"I can't do that, Hal." andMessage:@"You can only send feedback to saved stores"];
        
        [alertView addButtonWithTitle:@"Ok."
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  //Nothing Happens
                              }];
        [alertView show];
    }
    else{
        ComposeMessageViewController *composeVC = [[ComposeMessageViewController alloc] init];
        composeVC.messageType = @"Feedback";
        
        [self presentViewController:composeVC animated:YES completion:NULL];
        
    }

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
    //[self didDismissPresentedViewController];
}

@end
