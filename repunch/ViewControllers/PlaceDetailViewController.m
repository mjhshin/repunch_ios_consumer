//
//  PlaceDetailViewController.m
//  repunch
//
//  Created by CambioLabs on 3/25/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "PlacesViewController.h"
//#import "RewardDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "UIViewController+animateView.h"
#import "AppDelegate.h"
#import "ComposeViewController.h"

@interface PlaceDetailViewController ()

@end

@implementation PlaceDetailViewController

@synthesize placeRewardData, delegate, place, placeAddButton, placeAddOrRemove, placeBottomContainer, isSearch, placesDetailMapVC, placePunchesLabel;

- (id)init
{
    self = [super init];
    if (self) {
        isSearch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser valueForKey:@"username"]];
    
    //placeRewardData = [[NSMutableArray alloc] initWithArray:[[self._placerewards] allObjects]];
    [placeRewardData sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"required" ascending:YES]]];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    [placeTitleLabel setText:place.store_name];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, nil]];
    [self.view addSubview:placeToolbar];
    //... TO HERE.  END TOOLBAR.
    
    //THESE ARE STORE INFORMATION LABELS
    //FROM  HERE...
    UIImageView *placeImageView = [[UIImageView alloc] init];
    [placeImageView setImage:[UIImage imageWithData:self.place.store_avatar]];
    [placeImageView setFrame:CGRectMake(10, placeToolbar.frame.size.height + 10, 100, 100)];
    [self.view addSubview:placeImageView];
    
    UIView *placeDetails = [[UIView alloc] initWithFrame:CGRectMake(placeImageView.frame.origin.x + placeImageView.frame.size.width, placeToolbar.frame.size.height, self.view.frame.size.width - placeImageView.frame.origin.x - placeImageView.frame.size.width, 100)];
    [self.view addSubview:placeDetails];
    
    UILabel *placeCategoryLabel = [[UILabel alloc] init];
    placeCategoryLabel.font = [UIFont systemFontOfSize:12];
    placeCategoryLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
    placeCategoryLabel.frame = CGRectMake(10, 10, 200, 14);
    placeCategoryLabel.text = [[[self.place.categories allObjects] objectAtIndex:0] valueForKey:@"name"];
    [placeDetails addSubview:placeCategoryLabel];
    
    UILabel *placeAddressLabel = [[UILabel alloc] init];
    placeAddressLabel.font = [UIFont systemFontOfSize:12];
    placeAddressLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
    [placeAddressLabel setFrame:CGRectMake(10, placeCategoryLabel.frame.origin.y + placeCategoryLabel.frame.size.height, 200, 14)];
    [placeAddressLabel setText:[self.place valueForKey:@"street"]];
    [placeDetails addSubview:placeAddressLabel];
    
    UILabel *placeAddressLabel2 = [[UILabel alloc] init];
    placeAddressLabel2.font = [UIFont systemFontOfSize:12];
    placeAddressLabel2.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
    [placeAddressLabel2 setFrame:CGRectMake(10, placeAddressLabel.frame.origin.y + placeAddressLabel.frame.size.height, 200, 14)];
    [placeAddressLabel2 setText:[NSString stringWithFormat:@"%@, %@ %@",[self.place city], [self.place state], [self.place zip]]];
    [placeDetails addSubview:placeAddressLabel2];
    
    float hoursLabelTop = placeAddressLabel2.frame.origin.y + placeAddressLabel2.frame.size.height;
    //...TO HERE. END STORE INFO.
    
    
    /*
    
    //if user has saved place, also show how many punches they have
    if ([localUser hasPlace:self.place]){
        
        UIImage *punchImage = [UIImage imageNamed:([self.place.num_punches integerValue] == 0 ? @"ico_starburst-gray" : @"ico_starburst-orange")];
        UIImageView *placePunchesImageView = [[[UIImageView alloc] init]  ];
        [placePunchesImageView setImage:punchImage];
        [placePunchesImageView setFrame:CGRectMake(10, placeAddressLabel2.frame.origin.y + placeAddressLabel2.frame.size.height + 5, punchImage.size.width, punchImage.size.height)];
        [placeDetails addSubview:placePunchesImageView];
        
        int punches = (self.place.num_punches == nil ? 0 : [self.place.num_punches integerValue]);
        placePunchesLabel = [[[UILabel alloc] init]  ];
        [placePunchesLabel setText:[NSString stringWithFormat:(punches == 1 ? @"%d Punch" :  @"%d Punches"),punches]];
        placePunchesLabel.font = [UIFont boldSystemFontOfSize:13];
        [placePunchesLabel setFrame:CGRectMake(placePunchesImageView.frame.origin.x + placePunchesImageView.frame.size.width + 3, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height / 2 - 10, 150, 18)];
        [placePunchesLabel sizeToFit];
        [placeDetails addSubview:placePunchesLabel];
        
        hoursLabelTop = placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height;
        
    }
    
    UILabel *placeHoursLabel = [[[UILabel alloc] init]  ];
    [placeHoursLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [placeHoursLabel setFrame:CGRectMake(10, hoursLabelTop + 5, 200, 15)];
    [placeHoursLabel setText:@"Hours Today"];
    [placeDetails addSubview:placeHoursLabel];
    
    NSDateFormatter *formatter_out = [[[NSDateFormatter alloc] init]  ];
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
    NSArray *hoursArray = [[NSArray alloc] initWithArray:[[_placehours] allObjects]];
    for(HoursObject *ho in hoursArray) {
        if ([ho.day integerValue] == weekday) {
            
            NSString *openHour = [ho.open_time substringToIndex:2];
            NSString *openMinute = [ho.open_time substringFromIndex:2];
            
            NSString *closeHour = [ho.close_time substringToIndex:2];
            NSString *closeMinute = [ho.close_time substringFromIndex:2];
            
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]  ];
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
    
    UILabel *placeTimeLabel = [[[UILabel alloc] init]  ];
    [placeTimeLabel setFont:[UIFont systemFontOfSize:12]];
    [placeTimeLabel setFrame:CGRectMake(10, placeHoursLabel.frame.origin.y + placeHoursLabel.frame.size.height, 200, 15)];
    [placeTimeLabel setTextColor:[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1]];
    [placeTimeLabel setText:hourstodaystring];
    [placeTimeLabel sizeToFit];
    [placeDetails addSubview:placeTimeLabel];
    
    UILabel *placeOpenLabel = [[[UILabel alloc] init]  ];
    [placeOpenLabel setFont:[UIFont boldSystemFontOfSize:12]];
    CGRect frame = CGRectMake(placeTimeLabel.frame.origin.x + placeTimeLabel.frame.size.width, placeTimeLabel.frame.origin.y, 200, 15);
    if (![hourstodaystring isEqualToString:@""]) {
        frame.origin.x += 3;
    }
    [placeOpenLabel setFrame:frame];
    UIColor *openColor = [UIColor colorWithRed:104/255.f green:136/255.f blue:13/255.f alpha:1];
    UIColor *closedColor = [UIColor blackColor];
    [placeOpenLabel setTextColor:(open ? openColor : closedColor)];
    [placeOpenLabel setText:(open ? @"Open" : @"Closed")];
    [placeOpenLabel sizeToFit];
    [placeDetails addSubview:placeOpenLabel];
    
    placeAddOrRemove = [[UIView alloc] initWithFrame:CGRectMake(0, placeImageView.frame.origin.y + placeImageView.frame.size.height + 11, self.view.frame.size.width, 40)];
    [placeAddOrRemove setAutoresizesSubviews:NO];
    [placeAddOrRemove setClipsToBounds:YES];
    
    float placeActionsViewTop = placeImageView.frame.origin.y + placeImageView.frame.size.height;
    if (![localUser hasPlace:place]) {
        [self.view addSubview:placeAddOrRemove];
        placeActionsViewTop = placeAddOrRemove.frame.origin.y + placeAddOrRemove.frame.size.height;
    }
    
    //HERE ARE THE ADD REMOVE BUTTONS
    UIImage *placeAddImage = [UIImage imageNamed:@"btn-add-myplaces"];
    placeAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [placeAddButton addTarget:self action:@selector(addPlace) forControlEvents:UIControlEventTouchUpInside];
    [placeAddButton setFrame:CGRectMake(10, 0, placeAddImage.size.width, placeAddImage.size.height)];
    [placeAddButton setImage:placeAddImage forState:UIControlStateNormal];
    [placeAddButton setTitle:@"Add to My Places" forState:UIControlStateNormal];
    [placeAddOrRemove addSubview:placeAddButton];
    
    UIButton *placeRemoveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [placeRemoveButton addTarget:self action:@selector(removePlace) forControlEvents:UIControlEventTouchUpInside];
    [placeRemoveButton setFrame:CGRectMake(120, 0, 100, 40)];
    [placeRemoveButton setTitle:@"Remove" forState:UIControlStateNormal];
    //    [placeAddOrRemove addSubview:placeRemoveButton];
    
    placeBottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, placeActionsViewTop+10, self.view.frame.size.width, self.view.frame.size.height - 1 - 49)];
    
    UIView *placeActionsView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, 50)]  ];
    [placeActionsView setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1]];
    UIView *placeActionsViewBorderTop = [[[UIView alloc] initWithFrame:CGRectMake(0, placeActionsView.frame.origin.y - 1, self.view.frame.size.width, 1)]  ];
    UIView *placeActionsViewBorderBottom = [[[UIView alloc] initWithFrame:CGRectMake(0, placeActionsView.frame.origin.y + placeActionsView.frame.size.height, self.view.frame.size.width, 1)]  ];
    [placeActionsViewBorderTop setBackgroundColor:[UIColor colorWithRed:189/255.f green:190/255.f blue:189/255.f alpha:1]];
    [placeActionsViewBorderBottom setBackgroundColor:[UIColor colorWithRed:189/255.f green:190/255.f blue:189/255.f alpha:1]];
    
    UIButton *placeCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [placeCallButton addTarget:self action:@selector(placeCall) forControlEvents:UIControlEventTouchUpInside];
    [placeCallButton setFrame:CGRectMake(20, 0, 100, placeActionsView.frame.size.height)];
    [placeCallButton setTitle:@"Call" forState:UIControlStateNormal];
    [placeCallButton setTitleColor:[UIColor colorWithRed:36/255.f green:83/255.f blue:151/255.f alpha:1] forState:UIControlStateNormal];
    [placeCallButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [placeCallButton setImage:[UIImage imageNamed:@"ico-phone"] forState:UIControlStateNormal];
    [placeCallButton setTitleEdgeInsets:UIEdgeInsetsMake(placeActionsView.frame.size.height - 10, -45, 0, 0)];
    [placeCallButton setContentEdgeInsets:UIEdgeInsetsMake(-13, 0, 0, 0)];
    
    UIButton *placeMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [placeMapButton addTarget:self action:@selector(placeMap) forControlEvents:UIControlEventTouchUpInside];
    [placeMapButton setFrame:CGRectMake(120, 0, 100, placeActionsView.frame.size.height)];
    [placeMapButton setTitle:@"Map" forState:UIControlStateNormal];
    [placeMapButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [placeMapButton setTitleColor:[UIColor colorWithRed:36/255.f green:83/255.f blue:151/255.f alpha:1] forState:UIControlStateNormal];
    [placeMapButton setImage:[UIImage imageNamed:@"ico-map"] forState:UIControlStateNormal];
    [placeMapButton setTitleEdgeInsets:UIEdgeInsetsMake(placeActionsView.frame.size.height - 10, -48, 0, 0)];
    [placeMapButton setContentEdgeInsets:UIEdgeInsetsMake(-13, 0, 0, 0)];
    
    UIButton *placeFeedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [placeFeedbackButton addTarget:self action:@selector(placeFeedback) forControlEvents:UIControlEventTouchUpInside];
    [placeFeedbackButton setFrame:CGRectMake(240, 0, 100, placeActionsView.frame.size.height)];
    [placeFeedbackButton setTitle:@"Feedback" forState:UIControlStateNormal];
    [placeFeedbackButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [placeFeedbackButton setTitleColor:[UIColor colorWithRed:36/255.f green:83/255.f blue:151/255.f alpha:1] forState:UIControlStateNormal];
    [placeFeedbackButton setImage:[UIImage imageNamed:@"ico-feedback"] forState:UIControlStateNormal];
    [placeFeedbackButton setTitleEdgeInsets:UIEdgeInsetsMake(placeActionsView.frame.size.height - 10, -84, 0, 0)];
    [placeFeedbackButton setContentEdgeInsets:UIEdgeInsetsMake(-13, 0, 0, 0)];
    
    [placeActionsView addSubview:placeCallButton];
    [placeActionsView addSubview:placeMapButton];
    [placeActionsView addSubview:placeFeedbackButton];
    [placeBottomContainer addSubview:placeActionsView];
    [placeBottomContainer addSubview:placeActionsViewBorderTop];
    [placeBottomContainer addSubview:placeActionsViewBorderBottom];
    [self.view addSubview:placeBottomContainer];
    
    UITableView *placeRewardsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, placeActionsViewBorderBottom.frame.origin.y + 1, self.view.frame.size.width, self.view.frame.size.height - placeActionsViewBorderBottom.frame.origin.y - 1 - 49) style:UITableViewStylePlain];
    [placeRewardsTable setDataSource:self];
    [placeRewardsTable setDelegate:self];
    //    [placeRewardsTable setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:.5]];
    [placeBottomContainer addSubview:placeRewardsTable];
     */
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (placePunchesLabel != nil) {
        int punches = (self.place.num_punches == nil ? 0 : [self.place.num_punches integerValue]);
        [placePunchesLabel setText:[NSString stringWithFormat:(punches == 1 ? @"%d Punch" :  @"%d Punches"),punches]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad makeTabBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!isSearch) {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ad makeTabBarHidden:NO];
    }
}

#pragma mark - Place Selectors

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[placeRewardData objectAtIndex:indexPath.row] name];
    int required = [[[placeRewardData objectAtIndex:indexPath.row] required] integerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:(required == 1 ? @"%@ Punch" :  @"%@ Punches"),[[placeRewardData objectAtIndex:indexPath.row] required]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_reward-list-gradient"]]];
    
    // if required punches are greater than what we have, disable selection
    if ([[[placeRewardData objectAtIndex:indexPath.row] required] integerValue] > [self.place.num_punches integerValue]) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RewardDetailViewController *rdvc = [[RewardDetailViewController alloc] init];
    [rdvc setReward:[placeRewardData objectAtIndex:indexPath.row]];
    [rdvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [rdvc setParentVC:self];
    
    [self.view addSubview:rdvc.view];
}
 */

@end
