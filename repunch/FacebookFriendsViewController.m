//
//  FacebookFriendsViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 8/22/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "FacebookFriendsViewController.h"

@interface FacebookFriendsViewController ()

@end

@implementation FacebookFriendsViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.friendDictionary = [NSMutableDictionary dictionary];
	
	self.navigationItem.title = @"Choose A Friend";

	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																				target:self
																				action:@selector(closeButtonPressed)];
	self.navigationItem.leftBarButtonItem = exitButton;
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.tableView setTableFooterView:footer];
	
	self.allowsMultipleSelection = NO;
	self.itemPicturesEnabled = YES;
	self.sortOrdering = FBFriendSortByFirstName;
	self.displayOrdering = FBFriendDisplayByFirstName;
	self.doneButton = nil;
	self.cancelButton = nil;
	self.delegate = self;
	
	[self loadFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriends
{
	self.spinnerView.hidden = NO;
	[self.mySpinner startAnimating];
	
	[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if(!error)
		{
			NSArray* friends = result[@"data"];
			NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friends.count];

			for (NSDictionary<FBGraphUser>* friend in friends)
			{
				//NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
				[friendIds addObject:friend.id];
			}
			
			PFQuery *patronQuery = [PFQuery queryWithClassName:[RPPatron parseClassName]];
			[patronQuery whereKey:@"facebook_id" containedIn:friendIds];
			[patronQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
			{
				if(!error)
				{
					for(RPPatron *patron in results)
					{
						[self.friendDictionary setObject:patron.objectId forKey:patron.facebook_id];
					}
					[self loadData];
					self.spinner.hidden = YES;
				}
				else
				{
					self.spinnerView.hidden = YES;
					[self.mySpinner stopAnimating];
					
					[RepunchUtils showConnectionErrorDialog];
					[self dismissViewControllerAnimated:NO completion:nil];
				}
			}];
		}
		else
		{
			self.spinnerView.hidden = YES;
			[self.mySpinner stopAnimating];
			
			
			[RepunchUtils showDialogWithTitle:@"Sorry, something went wrong" withMessage:nil];
			[self dismissViewControllerAnimated:NO completion:nil];
		}
	}];
}

// Event: Error during data fetch
- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error
{
	NSLog(@"Error during data fetch.");
	self.spinnerView.hidden = YES;
	[self.mySpinner stopAnimating];
	[RepunchUtils showDefaultDropdownView:self.view];}

// Event: Data loaded
- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"Friend data loaded.");
	self.spinnerView.hidden = YES;
	[self.mySpinner stopAnimating];
}

// Event: Decide if a given user should be displayed
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <FBGraphUser>)user
{
    return self.friendDictionary[user.id] ? YES : NO;
}

// Event: Selection changed
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
	
	NSDictionary<FBGraphUser> *selection = friendPicker.selection[0];
	NSString *recepientId = self.friendDictionary[selection.id];

	[self dismissViewControllerAnimated:NO
                             completion:^{
								 [self.myDelegate onFriendSelected:self forFriendId:recepientId withName:selection.name];
                             }];
}

// Event: Done button clicked
- (void)facebookViewControllerDoneWasPressed:(id)sender
{
}

// Event: Cancel button clicked
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
}

- (void)closeButtonPressed
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
