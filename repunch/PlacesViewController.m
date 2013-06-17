//
//  PlacesViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlaceDetailViewController.h"
#import "GlobalToolbar.h"
#import "SettingsNavigationController.h"
#import "UIViewController+animateView.h"
#import "Retailer.h"
#import "AppDelegate.h"

@implementation PlacesViewController

@synthesize placesData, placesTableView, settingsNavVC, placesDetailVC, searchVC, delegate, isSearch, location, myRelatedPlaces;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"My Places", @"My Places");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-places-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-places"]];
        isSearch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIToolbar *globalToolbar;
    if (!isSearch) {
        globalToolbar = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        [(GlobalToolbar *)globalToolbar setDelegate:self];
    } else {
        UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *closeButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closeButton] autorelease];
        
        UILabel *searchTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 46)] autorelease];
        [searchTitle setText:@"Search"];
        [searchTitle setFont:[UIFont boldSystemFontOfSize:20]];
        [searchTitle setTextColor:[UIColor whiteColor]];
        [searchTitle setBackgroundColor:[UIColor clearColor]];
        [searchTitle setShadowOffset:CGSizeMake(0, -1)];
        [searchTitle setShadowColor:[UIColor blackColor]];
        [searchTitle sizeToFit];
        
        UIBarButtonItem *searchTitleItem = [[[UIBarButtonItem alloc] initWithCustomView:searchTitle] autorelease];
        
        globalToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        [globalToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flex2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        [globalToolbar setItems:[NSArray arrayWithObjects:closeButtonItem, flex, searchTitleItem, flex2, nil]];
        
        if ([CLLocationManager locationServicesEnabled]) {
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
                self.location = geoPoint;
                [self setDistances];
                [self sortPlaces];
            }];
        }
    }
    [self.view addSubview:globalToolbar];
    
    placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, globalToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - globalToolbar.frame.size.height - (isSearch ? 0 : 49)) style:UITableViewStylePlain];
    [placesTableView setDataSource:self];
    [placesTableView setDelegate:self];
    [self.view addSubview:placesTableView];
    
    placesData = [[NSMutableArray alloc] initWithCapacity:0];
    
}

- (void)loadPlacesForSearch
{
    PFUser *pfuser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
    
    NSMutableArray *searchPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        for (PFObject *place in objects){
            Retailer *newPlace = [[Retailer alloc] initWithEntity:[NSEntityDescription entityForName:@"Retailer" inManagedObjectContext:localContext] insertIntoManagedObjectContext:localContext];
            [newPlace setFromParse:place];
            [newPlace setUser:nil];

            // set num punches from parse which is in the user object
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"retailer_id = %@",[place objectForKey:@"retailer_id"]];
            NSArray *userplaces = [myRelatedPlaces filteredArrayUsingPredicate:predicate];
            
            NSNumber *punches = [NSNumber numberWithInt:0];
            if ([userplaces count] > 0) {
                NSDictionary *userplace = [userplaces objectAtIndex:0];
                punches = [userplace objectForKey:@"num_punches"];
            }
            [newPlace setNum_punches:(punches != nil ? punches : [NSNumber numberWithInt:0])];
            
            // set distanct from current location
            if (self.location != nil) {
                PFGeoPoint *pfgp = [PFGeoPoint geoPointWithLatitude:[newPlace.latitude doubleValue] longitude:[newPlace.longitude doubleValue]];
                
                [newPlace setDistance:[NSNumber numberWithDouble:[self.location distanceInMilesTo:pfgp]]];
            }

            [searchPlaces addObject:newPlace];
        }
        
        placesData = searchPlaces;
        [self sortPlaces];
    }];
}

- (void)setDistances
{
    if (self.location != nil) {
        for (Retailer *newPlace in placesData){
            PFGeoPoint *pfgp = [PFGeoPoint geoPointWithLatitude:[newPlace.latitude doubleValue] longitude:[newPlace.longitude doubleValue]];
            
            [newPlace setDistance:[NSNumber numberWithDouble:[self.location distanceInMilesTo:pfgp]]];
        }
    }
}

- (void)loadPlaces
{
    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
    
    // For testing only -- BROKEN
//    if ([placesData count] == 0 && [[pfuser objectForKey:@"my_places"] count] == 0) {
//        [self fillPlacesDefault:YES];
//    }
    
    [[[pfuser relationforKey:@"my_places"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error) {
            NSLog(@"place count error: %@",error);
        } else {
            myRelatedPlaces = [[NSArray alloc] initWithArray:objects];
            
            // local and parse are out of sync so get parse and overwrite local
            if ([placesData count] != [myRelatedPlaces count]){
                [self fillPlacesDefault:NO];
            } else {
                [self sortPlaces];
            }
        }
    }];
}

/******************
 
 - Get user places from parse
 - For testing, add all places to new user with no places with defaultplaces = YES
 - defaultplaces = YES is BROKEN
 
 *****************/
- (void)fillPlacesDefault:(BOOL)defaultplaces
{
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
    
    if (!defaultplaces) {
        [query whereKey:@"retailer_id" containedIn:[myRelatedPlaces valueForKey:@"retailer_id"]];
    }
    
//    NSMutableArray *my_places = [[NSMutableArray alloc] initWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        
        // punches only get set for default places, i.e. filler
        int punches = 0;
        for (PFObject *place in objects){
            Retailer *newPlace = [Retailer MR_findFirstByAttribute:@"retailer_id" withValue:[place objectForKey:@"retailer_id"]];
            if (newPlace == nil) {
                newPlace = [Retailer MR_createInContext:localContext];
            }
            
            [newPlace setFromParse:place];
            [newPlace setUser:localUser];
            if (defaultplaces) {
                [newPlace setNum_punches:[NSNumber numberWithInt:punches]];
            } else {
                // set num punches from parse which is in the user object
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"retailer_id = %@",[place objectForKey:@"retailer_id"]];
                NSDictionary *userplace = [[myRelatedPlaces filteredArrayUsingPredicate:predicate] objectAtIndex:0];
                [newPlace setNum_punches:[userplace objectForKey:@"num_punches"]];
            }
            [localContext MR_saveToPersistentStoreAndWait];
            
//            [my_places addObject:[NSDictionary dictionaryWithObjectsAndKeys:[place objectForKey:@"Id"], @"retailer_id", [NSNumber numberWithInt:punches], @"num_punches", nil]];
            
            punches += 5;
        }
        
        // if user places, it came from parse in the first place, so don't resave
        if (defaultplaces) {
//            [pfuser setObject:my_places forKey:@"my_places_temp"];
//            [pfuser save];
        }
        
        placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
        [self sortPlaces];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self sortPlaces];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isSearch) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeTabBarHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (isSearch) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeTabBarHidden:NO];
    }
}

- (void)sortPlaces
{
    if (isSearch && self.location != nil) {
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease]]] retain];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"sort"] isEqualToString:@"Number of Rewards"]) {
        // sort by number of rewards descending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            int count1 = [[obj1 valueForKey:@"rewards"] count];
            int count2 = [[obj2 valueForKey:@"rewards"] count];
            
            if(count1 > count2){
                return (NSComparisonResult)NSOrderedDescending;
            } else if(count2 > count1){
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }] retain];
    } else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"sort"] isEqualToString:@"Number of Punches"]){
        // sort by punches descending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            int count1 = [[obj1 num_punches] integerValue];
            int count2 = [[obj2 num_punches] integerValue];
            
            if(count1 > count2){
                return (NSComparisonResult)NSOrderedDescending;
            } else if(count2 > count1){
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }] retain];
    } else {
        // sort by name ascending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]] retain];
    }
    
    [self.placesTableView reloadData];
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
    return [placesData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Retailer *thisPlace = [placesData objectAtIndex:indexPath.row];
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    
#define PLACEIMAGEVIEW_TAG 1
#define PLACENAMELABEL_TAG 2
#define PLACEADDRESSLABEL_TAG 3
#define PLACEPUNCHESLABEL_TAG 4
#define PLACEPUNCHESIMAGE_TAG 5
#define PLACEREWARDIMAGE_TAG 6
#define PLACEREWARDLABEL_TAG 7
#define PLACECATEGORYLABEL_TAG 8
#define PLACEDISTANCELABEL_TAG 9
    
    UIImageView *placeImageView, *placePunchesImageView, *placeRewardImageView;
    UILabel *placeNameLabel, *placeAddressLabel, *placePunchesLabel, *placeRewardLabel, *placeCategoryLabel, *placeDistanceLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UIView *placeDetails = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)] autorelease];
        placeImageView = [[[UIImageView alloc] init] autorelease];
        placeImageView.tag = PLACEIMAGEVIEW_TAG;
        [placeImageView setFrame:CGRectMake(11, 10, 90, 90)];
        [placeDetails addSubview:placeImageView];
        
        placeNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110, 10, 200, 18)] autorelease];
        placeNameLabel.tag = PLACENAMELABEL_TAG;
        placeNameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [placeDetails addSubview:placeNameLabel];
        
        placeCategoryLabel = [[[UILabel alloc] init] autorelease];
        placeCategoryLabel.tag = PLACECATEGORYLABEL_TAG;
        placeCategoryLabel.font = [UIFont systemFontOfSize:12];
        placeCategoryLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        placeCategoryLabel.frame = CGRectMake(110, placeNameLabel.frame.origin.y + placeNameLabel.frame.size.height + 2, 200, 14);
        [placeDetails addSubview:placeCategoryLabel];
        
        placeAddressLabel = [[[UILabel alloc] init] autorelease];
        placeAddressLabel.tag = PLACEADDRESSLABEL_TAG;
        placeAddressLabel.font = [UIFont systemFontOfSize:12];
        placeAddressLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeAddressLabel setFrame:CGRectMake(110, placeCategoryLabel.frame.origin.y + placeCategoryLabel.frame.size.height, 200, 14)];
        [placeDetails addSubview:placeAddressLabel];
        
        placeDistanceLabel = [[[UILabel alloc] init] autorelease];
        placeDistanceLabel.tag = PLACEDISTANCELABEL_TAG;
        placeDistanceLabel.font = [UIFont systemFontOfSize:12];
        placeDistanceLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        placeDistanceLabel.frame = CGRectMake(110, placeAddressLabel.frame.origin.y + placeAddressLabel.frame.size.height, 200, 14);
        [placeDistanceLabel setHidden:YES];
        [placeDetails addSubview:placeDistanceLabel];
        
        placePunchesLabel = [[[UILabel alloc] init] autorelease];
        placePunchesLabel.tag = PLACEPUNCHESLABEL_TAG;
        placePunchesLabel.font = [UIFont boldSystemFontOfSize:13];
        [placeDetails addSubview:placePunchesLabel];
        
        placePunchesImageView = [[[UIImageView alloc] init] autorelease];
        placePunchesImageView.tag = PLACEPUNCHESIMAGE_TAG;
        [placeDetails addSubview:placePunchesImageView];
        
        placeRewardImageView = [[[UIImageView alloc] init] autorelease];
        placeRewardImageView.tag = PLACEREWARDIMAGE_TAG;
        [placeDetails addSubview:placeRewardImageView];
        
        placeRewardLabel = [[[UILabel alloc] init] autorelease];
        placeRewardLabel.tag = PLACEREWARDLABEL_TAG;
        placeRewardLabel.font = [UIFont systemFontOfSize:12];
        placeRewardLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeDetails addSubview:placeRewardLabel];
        
        [cell.contentView addSubview:placeDetails];
        
        [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_place-list-gradient"]] autorelease]];
    } else {
        placeImageView = (UIImageView *)[cell.contentView viewWithTag:PLACEIMAGEVIEW_TAG];
        placeNameLabel = (UILabel *)[cell.contentView viewWithTag:PLACENAMELABEL_TAG];
        placeAddressLabel = (UILabel *)[cell.contentView viewWithTag:PLACEADDRESSLABEL_TAG];
        placeCategoryLabel = (UILabel *)[cell.contentView viewWithTag:PLACECATEGORYLABEL_TAG];
        placeDistanceLabel = (UILabel *)[cell.contentView viewWithTag:PLACEDISTANCELABEL_TAG];
        
        placePunchesLabel = (UILabel *)[cell.contentView viewWithTag:PLACEPUNCHESLABEL_TAG];
        placePunchesImageView = (UIImageView *)[cell.contentView viewWithTag:PLACEPUNCHESIMAGE_TAG];
        placeRewardLabel = (UILabel *)[cell.contentView viewWithTag:PLACEREWARDLABEL_TAG];
        placeRewardImageView = (UIImageView *)[cell.contentView viewWithTag:PLACEREWARDIMAGE_TAG];
    }
    
    // Configure the cell...
    if (isSearch && thisPlace.distance != nil && [thisPlace.distance integerValue] != 0){
        [placeDistanceLabel setHidden:NO];
    }
    
    [placeImageView setImage:[UIImage imageWithData:[[placesData objectAtIndex:indexPath.row] image_url]]];
    
    [placeNameLabel setText:[thisPlace name]];
    
    [placeAddressLabel setText:[thisPlace valueForKey:@"address"]];
    [placeCategoryLabel setText:[[[thisPlace.categories allObjects] objectAtIndex:0] valueForKey:@"name"]];
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:1];
    [formatter setMinimumFractionDigits:0];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    [placeDistanceLabel setText:[NSString stringWithFormat:@"%@ Miles",[formatter stringFromNumber:thisPlace.distance]]];
    
    if (!isSearch || [localUser hasPlace:thisPlace]){
    
        Retailer *myThisPlace = [Retailer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user = %@ && retailer_id = %@",localUser,thisPlace.retailer_id]];
        
        int punches = 0;
        if (myThisPlace != nil) {
            punches = (myThisPlace.num_punches == nil ? 0 : [myThisPlace.num_punches integerValue]);
        }
        UIImage *punchImage = [UIImage imageNamed:(punches == 0 ? @"ico_starburst-gray" : @"ico_starburst-orange")];
        [placePunchesImageView setImage:punchImage];
        [placePunchesImageView setFrame:CGRectMake(110, placeAddressLabel.frame.origin.y + placeAddressLabel.frame.size.height + 22, punchImage.size.width, punchImage.size.height)];
        
        [placePunchesLabel setText:[NSString stringWithFormat:(punches == 1 ? @"%d Punch" :  @"%d Punches"),punches]];
        [placePunchesLabel setFrame:CGRectMake(placePunchesImageView.frame.origin.x + placePunchesImageView.frame.size.width + 3, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height / 2 - 9, 150, 18)];
        [placePunchesLabel sizeToFit];
        
        NSArray *thisPlaceRewards = [[[NSArray alloc] initWithArray:[Reward MR_findByAttribute:@"place" withValue:thisPlace andOrderBy:@"required" ascending:YES]] autorelease];
        
        UIImage *rewardImage = [UIImage imageNamed:@"ico_reward"];
        [placeRewardImageView setImage:rewardImage];
        
        // show if there are enough punches for a reward
        if ([thisPlaceRewards count] > 0 && punches > [[[thisPlaceRewards objectAtIndex:0] required] integerValue]) {
            [placeRewardImageView setFrame:CGRectMake(225, placeAddressLabel.frame.origin.y + placeAddressLabel.frame.size.height + 23, rewardImage.size.width, rewardImage.size.height)];
            
            [placeRewardLabel setText:@"Reward"];
            [placeRewardLabel setFrame:CGRectMake(placeRewardImageView.frame.origin.x + placeRewardImageView.frame.size.width + 5, placeRewardImageView.frame.origin.y + placeRewardImageView.frame.size.height / 2 - 7, 200, 14)];
            [placeRewardLabel setBackgroundColor:[UIColor clearColor]];
            [placeRewardLabel sizeToFit];
        }
        
    } else {
        // reset these so they don't get reused
        [placePunchesLabel setText:@""];
        [placePunchesImageView setImage:nil];
        [placeRewardLabel setText:@""];
        [placeRewardImageView setImage:nil];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 113;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    
    Retailer *thisPlace = [placesData objectAtIndex:indexPath.row];
    if ([localUser hasPlace:thisPlace]) {
        thisPlace = [Retailer MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"user = %@ && retailer_id = %@",localUser, thisPlace.retailer_id]];
    }
    
    placesDetailVC = [[PlaceDetailViewController alloc] init];
    [placesDetailVC setIsSearch:isSearch];
    [placesDetailVC setPlace:thisPlace];
    [placesDetailVC setDelegate:self];
    [placesDetailVC.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:placesDetailVC.view];
    [self animateView:placesDetailVC.view up:YES distance:self.view.frame.size.height completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Global Toolbar Delegate

- (void) openSettings
{
    settingsNavVC = [[SettingsNavigationController alloc] init];
    [settingsNavVC setDelegate:self];
    [settingsNavVC.navigationBar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forBarMetrics:UIBarMetricsDefault];
    [settingsNavVC.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:settingsNavVC.view];
    [self animateView:settingsNavVC.view up:YES distance:self.view.frame.size.height completion:nil];
}

- (void) closeSettings
{
    [self viewWillAppear:NO];
    [self animateView:settingsNavVC.view
                   up:NO
             distance:self.view.frame.size.height
           completion:^(BOOL finished){
               [settingsNavVC.view removeFromSuperview];
           }];
}

- (void) openSearch
{
    searchVC = [[PlacesViewController alloc] init];
    [searchVC setIsSearch:YES];
    [searchVC setDelegate:self];
    [searchVC.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:searchVC.view];
    [self animateView:searchVC.view up:YES distance:self.view.frame.size.height completion:nil];
    [searchVC loadPlacesForSearch];
}

- (void) closeSearch
{
    if (delegate != nil) {
        [(PlacesViewController *)delegate closeSearch];
    } else {
        
        PFUser *pfuser = [PFUser currentUser];
        User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
        placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
        
        [self viewWillAppear:NO];
        [self animateView:searchVC.view up:NO distance:self.view.frame.size.height completion:^(BOOL finished){
            [searchVC.view removeFromSuperview];
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSArray *searchPlaces = [Retailer MR_findByAttribute:@"user" withValue:nil];
            for (Retailer *place in searchPlaces){
                [place MR_deleteEntity];
            }
            [localContext MR_saveToPersistentStoreAndWait];
        }];
    }
}

#pragma mark - Place Detail Delegate

- (void)closePlaceDetail
{
    [self viewWillAppear:NO];
    [self animateView:placesDetailVC.view
                   up:NO
             distance:self.view.frame.size.height
           completion:^(BOOL finished){
               [placesDetailVC.view removeFromSuperview];
           }];
}

@end
