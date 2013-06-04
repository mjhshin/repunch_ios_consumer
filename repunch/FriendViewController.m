//
//  FriendViewController.m
//  repunch
//
//  Created by CambioLabs on 5/14/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "FriendViewController.h"
#import "ComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendViewController ()

@end

@implementation FriendViewController

@synthesize friendData, friendTableView, alphabet, reward, parentVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    alphabet = [[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",
                @"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    UIToolbar *friendToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)] autorelease];
    [friendToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closeFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeFriendButton setImage:closeImage forState:UIControlStateNormal];
    [closeFriendButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeFriendButton addTarget:self action:@selector(closeFriend) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeFriendButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closeFriendButton] autorelease];
    
    UILabel *friendTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(closeFriendButton.frame.size.width, 0, friendToolbar.frame.size.width - closeFriendButton.frame.size.width - 25, friendToolbar.frame.size.height)] autorelease];
    [friendTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [friendTitleLabel setBackgroundColor:[UIColor clearColor]];
    [friendTitleLabel setTextColor:[UIColor whiteColor]];
    [friendTitleLabel setText:@"Choose a Friend"];
    [friendTitleLabel sizeToFit];
    
    UIBarButtonItem *friendTitleItem = [[[UIBarButtonItem alloc] initWithCustomView:friendTitleLabel] autorelease];
    
    UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *flex2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    [friendToolbar setItems:[NSArray arrayWithObjects:closeFriendButtonItem, flex, friendTitleItem, flex2, nil]];
    [self.view addSubview:friendToolbar];
    
    friendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, friendToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - friendToolbar.frame.size.height)];
    [friendTableView setDataSource:self];
    [friendTableView setDelegate:self];
    [self.view addSubview:friendTableView];
        
    FBRequest *friendListRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture"];
    
    [friendListRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (error) {
            NSLog(@"FB Friend Request error: %@",error);
            // error = { code = 190; "error_subcode" = 460; message = "invalid access token; changed password or security; log in again"
        } else {
            NSMutableArray * fbfriendData = [result objectForKey:@"data"];
            
            PFQuery *pffriendquery = [PFUser query];
            [pffriendquery whereKey:@"facebook_id" containedIn:[fbfriendData valueForKey:@"id"]];
            
            [pffriendquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if (error) {
                    NSLog(@"Error getting pffriends: %@", error);
                } else {
                    friendData = [[NSMutableArray alloc] initWithArray:[fbfriendData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id in %@",[objects valueForKey:@"facebook_id"]]]];
                    
                    friendData = [[NSMutableArray alloc] initWithArray:[friendData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]]];
                    
                    [friendTableView reloadData];
                }
            }];
            
            
        }
    }];
}

- (void)closeFriend
{
    [parentVC viewWillAppear:NO];
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [alphabet count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return alphabet;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", [alphabet objectAtIndex:section]];
    NSMutableArray *array_letter = [NSMutableArray arrayWithArray:[friendData filteredArrayUsingPredicate:predicateString]];
    
    if([array_letter count] <= 0)
    {
        return nil;
    }
    
    return [alphabet objectAtIndex:section];
}

// Where to jump to when index is touched
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [alphabet indexOfObject:title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", [alphabet objectAtIndex:section]];
    return [[NSMutableArray arrayWithArray:[friendData filteredArrayUsingPredicate:predicateString]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", [alphabet objectAtIndex:indexPath.section]];
    NSMutableArray *array_letter = [NSMutableArray arrayWithArray:[friendData filteredArrayUsingPredicate:predicateString]];
    
    [cell.textLabel setText:[[array_letter objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    [cvc setReward:reward];
    [cvc setComposeType:@"gift"];
    [cvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [cvc setParentVC:self];
    
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"name beginswith[cd] %@", [alphabet objectAtIndex:indexPath.section]];
    NSMutableArray *array_letter = [NSMutableArray arrayWithArray:[friendData filteredArrayUsingPredicate:predicateString]];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"facebook_id" equalTo:[[array_letter objectAtIndex:indexPath.row] objectForKey:@"id"]];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [cvc setRecipient:[objects objectAtIndex:0]];
        
        [self.view addSubview:cvc.view];
    }];
    
}

@end
