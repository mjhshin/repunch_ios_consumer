//
//  RepunchFriendsViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "RepunchFriendsViewController.h"
#import "ComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@implementation RepunchFriendsViewController{
    __block NSArray *friendsOnRepunchArray;
    UITableView *friendsTableView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    friendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, self.view.frame.size.height - 47) style:UITableViewStylePlain];
    [friendsTableView setDataSource:self];
    [friendsTableView setDelegate:self];
    
    [[self view] addSubview:friendsTableView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Query Patron for instances where value of column "facebook_id" is contained in the array friendIds
            PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
            [patronQuery whereKey:@"facebook_id" containedIn:friendIds];
            
            //execute the query
            [patronQuery findObjectsInBackgroundWithBlock:^(NSArray *fetchedRepunchFriendsArray, NSError *error) {
                friendsOnRepunchArray = fetchedRepunchFriendsArray;
                [friendsTableView reloadData];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendsOnRepunchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFObject *friendForThisCell = [friendsOnRepunchArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [friendForThisCell valueForKey:@"first_name"], [friendForThisCell valueForKey:@"last_name"]];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    composeVC.modalDelegate = self;
    composeVC.messageType = @"Gift";
    composeVC.sendParameters = _giftParametersDict;
    composeVC.recipient = [friendsOnRepunchArray objectAtIndex:indexPath.row];
    
    [self presentViewController:composeVC animated:YES completion:NULL];
}

#pragma mark - Modal delegate

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];;
}


- (IBAction)closePage:(id)sender {
    [[self modalDelegate] didDismissPresentedViewController];
}
@end
