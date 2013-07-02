//
//  PlacesDetailViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PlacesDetailViewController.h"
#import "PlacesDetailMapViewController.h"
#import "SIAlertView.h"
#import "User.h"
#import "PatronStore.h"
#import "Reward.h"
#import "RewardCell.h"
#import "AppDelegate.h"
#import "ComposeViewController.h"

//TODO: make sure all alert dialogues match

@implementation PlacesDetailViewController{
    NSMutableArray *placeRewardData;
    PlacesDetailMapViewController *placesDetailMapVC;
    User *localUser;
    int availablePunches;
    PatronStore *patronStoreEntity;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [_rewardsTable reloadData];
    
    placeRewardData = [[[_storeObject mutableSetValueForKey:@"rewards"] allObjects] mutableCopy];

    patronStoreEntity= [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, _storeObject.objectId]];
    availablePunches = [[patronStoreEntity punch_count] intValue];
    
    if (!_isSavedStore){
        [_numPunches setText:@""];
        [_feedbackBtn setImage:[UIImage imageNamed:@"ico-feedback-block"] forState:UIControlStateNormal];
    }
    else{
        int punches = [[patronStoreEntity punch_count] intValue];
        [_numPunches setText:[NSString stringWithFormat:@"%d %@", punches, (punches==1)?@"punch":@"punches"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillAppear:)
                                                 name:@"receivedPush"
                                               object:nil];


}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedPush" object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];
    _isSavedStore = [localUser alreadyHasStoreSaved:[_storeObject objectId]];
    
    //_scrollView.scrollEnabled = YES;
    
    //THIS IS A TOOLBAR
    //FROM HERE...
    UIToolbar *placeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(closePlaceDetail) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closePlaceButton];
    
    UILabel *placeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)];
    [placeTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:[_storeObject valueForKey:@"store_name"]];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *addOrRemoveImage;
    
    if (!_isSavedStore) addOrRemoveImage = [UIImage imageNamed:@"ab_add_my_places"];
    else addOrRemoveImage = [UIImage imageNamed:@"ab_message_delete"];
    UIButton *addOrRemoveButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [addOrRemoveButton setImage:addOrRemoveImage forState:UIControlStateNormal];
    [addOrRemoveButton setFrame:CGRectMake(0, 0, addOrRemoveImage.size.width, addOrRemoveImage.size.height)];
    [addOrRemoveButton addTarget:self action:@selector(addOrRemovePlace) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addOrRemoveTitle = [[UIBarButtonItem alloc] initWithCustomView:addOrRemoveButton];
    
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, addOrRemoveTitle, nil]];
    [self.view addSubview:placeToolbar];
    //... TO HERE.  END TOOLBAR.
    
    _storePic.image = [UIImage imageWithData:_storeObject.store_avatar];

    NSString *addressString = [_storeObject valueForKey:@"street"];
    if ([[_storeObject valueForKey:@"cross_streets"] length]>0) addressString = [addressString stringByAppendingFormat:@"\n%@",[_storeObject valueForKey:@"cross_streets"]];
    if ([[_storeObject valueForKey:@"neighborhood"] length]>0)addressString = [addressString stringByAppendingFormat:@"\n%@",[_storeObject valueForKey:@"neighborhood"]];
    addressString = [addressString stringByAppendingFormat:@"\n%@, %@ %@",[_storeObject valueForKey:@"city"], [_storeObject valueForKey:@"state"], [_storeObject valueForKey:@"zip"]];
    _storeAddress.text = addressString;
    _storeHours.text = [self getHoursString];
    
    placeRewardData = [[[_storeObject mutableSetValueForKey:@"rewards"] allObjects] mutableCopy];
    NSLog(@"rewards are :%@", [placeRewardData valueForKey:@"reward_name"]);
    
    [placeRewardData sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"punches" ascending:YES]]];
    
    //  trying to resize the table view ugh.  NOTHING WORKS I DON'T UNDERSTAND LIFE ANYMORE.
    //_rewardsTable = [[UITableView alloc] initWithFrame:CGRectMake(_rewardsTable.frame.origin.x, _rewardsTable.frame.origin.y, _rewardsTable.frame.size.width,(60.0f*([placeRewardData count])))];

    [_rewardsTable setDataSource:self];
    [_rewardsTable setDelegate:self];
    
    [_scrollView setContentSize:CGSizeMake(320, [self bottomOfLowestContent:[self view]])];

}


#pragma mark - Self Helper Methods
- (CGFloat) bottomOfLowestContent:(UIView*) view
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

-(NSString *)getHoursString{
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
    if (_isSavedStore){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        Reward *currentCellReward = [placeRewardData objectAtIndex:indexPath.row];

        int required = [[currentCellReward punches] intValue];
        if (availablePunches >= required){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@.", [currentCellReward reward_name]] andMessage:[NSString stringWithFormat:@"It'll cost you %@.", [NSString stringWithFormat:(required == 1 ? @"%i Punch" :  @"%i Punches"), required]]];
            
            [alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      //Nothing Happens
                                  }];
            [alertView addButtonWithTitle:@"Redeem"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_storeObject objectId], @"store_id",[patronStoreEntity objectId], @"patron_store_id", [currentCellReward reward_name], @"title", [currentCellReward objectId], @"reward_id", [currentCellReward punches], @"num_punches",   nil];

                                      [PFCloud callFunctionInBackground:@"request_redeem"
                                                         withParameters:functionArguments
                                                                  block:^(NSString *success, NSError *error) {
                                                                      if (!error){
                                                                          NSLog(@"function call is :%@", success);
                                                                      }
                                                                      else
                                                                          NSLog(@"error occurred: %@", error);
                                                                  }];
                                      NSLog(@"Redeem Clicked");
                                  }];
            [alertView addButtonWithTitle:@"Gift"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      //CAN'T DO THIS WITHOUT FACEBOOK OR SOMETHING
                                      NSLog(@"Gift Clicked");
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

            [alertView show];
        }
        else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@.", [[placeRewardData objectAtIndex:indexPath.row] valueForKey:@"reward_name"]] andMessage:[NSString stringWithFormat:@"You don't have %@.", [NSString stringWithFormat:(required == 1 ? @"%i Punch" :  @"%i Punches"), required]]];
            
            [alertView addButtonWithTitle:@"Shucks."
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

    PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
    [patronQuery getObjectInBackgroundWithId:localUser.patronId block:^(PFObject *patronObject, NSError *error) {
        if (!error){
            if (!_isSavedStore){
                //TODO: way to check if patron store has already been added
                
                //create new Patron Store
                PFObject *patronStore = [PFObject objectWithClassName:@"PatronStore"];
                [patronStore setValue: patronObject forKey:@"Patron"];
                PFQuery *storeQuery = [PFQuery queryWithClassName:@"Store"];
                    [storeQuery getObjectInBackgroundWithId:_storeObject.objectId block:^(PFObject *fetchedStore, NSError *error) {
                        [patronStore setValue: fetchedStore forKey:@"Store"];
                        [patronStore setValue:[NSNumber numberWithInt:0] forKey:@"punch_count"];
                        [patronStore setValue:[NSNumber numberWithInt:0]  forKey:@"all_time_punches"];
                        [patronStore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            //add it to Patron object's saved stores
                            PFRelation *relation = [patronObject relationforKey:@"PatronStores"];
                            [relation addObject:patronStore];
                            [patronObject saveInBackground];
                            
                            PFRelation *storeRelation = [fetchedStore relationforKey:@"PatronStores"];
                            [storeRelation addObject:patronStore];
                            [fetchedStore saveInBackground];

                        }];


                    }];
                PatronStore *newPatronStoreEntity = [PatronStore MR_createEntity];
                [newPatronStoreEntity setFromPatronObject:patronStore andStoreEntity:_storeObject andUserEntity:localUser];
                [localUser addSaved_storesObject:newPatronStoreEntity];
                [localContext MR_saveToPersistentStoreAndWait];
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Added!" andMessage:[NSString stringWithFormat:@"You've saved %@", [_storeObject valueForKey:@"store_name"]]];
                
                [alertView addButtonWithTitle:@"Sweet beans."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          //[[self modalDelegate] didDismissPresentedViewController];
                                          _isSavedStore = TRUE;
                                          [self viewDidLoad];
                                      }];
                [alertView show];


            }
            else{
                SIAlertView *warningView = [[SIAlertView alloc] initWithTitle:@"Warning! Point of No Return" andMessage:[NSString stringWithFormat:@"Are you sure you want to remove %@? You will lose ALL the punches", [_storeObject valueForKey:@"store_name"]]];
                [warningView addButtonWithTitle:@"Mm.  Nah."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          
                                      }];

                
                [warningView addButtonWithTitle:@"Bring it."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          
                                          //get patron store
                                          PFQuery *patronStoreQuery = [PFQuery queryWithClassName:@"PatronStore"];
                                          [patronStoreQuery whereKey:@"Store" equalTo:[PFObject objectWithoutDataWithClassName:@"Store" objectId:_storeObject.objectId]];
                                          [patronStoreQuery whereKey:@"Patron" equalTo:[PFObject objectWithoutDataWithClassName:@"Patron" objectId:localUser.patronId]];
                                          [patronStoreQuery getFirstObjectInBackgroundWithBlock:^(PFObject *patronStoreObject, NSError *error) {
                                              //remove it from Patron object
                                              [patronStoreObject deleteInBackground];
                                              [patronObject saveInBackground];
                                              
                                              //get patronStore and delete it
                                              PatronStore *storeToDelete = [PatronStore MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patron_id = %@ && store_id = %@", localUser.patronId, _storeObject.objectId]];
                                              [localContext deleteObject:storeToDelete];
                                              
                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Removed!" andMessage:[NSString stringWithFormat:@"You've removed %@", [_storeObject valueForKey:@"store_name"]]];
                                              
                                              [alertView addButtonWithTitle:@"Awesome sauce."
                                                                       type:SIAlertViewButtonTypeDefault
                                                                    handler:^(SIAlertView *alert) {
                                                                        [[self modalDelegate] didDismissPresentedViewController];
                                                                    }];
                                              [alertView show];
                                              
                                              
                                              [localContext MR_saveToPersistentStoreAndWait];
                                          }];
                                      }];
                [warningView show];

            }
            
        } else NSLog(@"error is %@", error);
    }];

}

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];;
}

- (IBAction)callButton:(id)sender {
    NSString *number = [_storeObject phone_number];
    NSString *phoneNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [number length])];
    NSString *phoneNumberUrl = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberUrl]];

}

- (IBAction)mapButton:(id)sender {
    placesDetailMapVC = [[PlacesDetailMapViewController alloc] init];
    [placesDetailMapVC setModalDelegate:self];
    [placesDetailMapVC setPlace:_storeObject];
    placesDetailMapVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [placesDetailMapVC.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self presentViewController:placesDetailMapVC animated:YES completion:NULL];
    

}

- (IBAction)feedbackButton:(id)sender {
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
         ComposeViewController *composeVC = [[ComposeViewController alloc] init];
        composeVC.modalDelegate = self;
        composeVC.storeObject = _storeObject;
        
        [self presentViewController:composeVC animated:YES completion:NULL];
        
    }
    

}
@end
