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
	
	UIView *toolbar = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = toolbar.bounds;
	[toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	[closeButton setImage:[UIImage imageNamed:@"nav_exit.png"] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[toolbar addSubview:closeButton];
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"Choose A Friend";
	[titleLabel sizeToFit];
	[toolbar addSubview:titleLabel];
	[titleLabel setCenter:toolbar.center];
	[self.view addSubview:toolbar];
	
	CGRect tableFrame = self.tableView.frame;
	tableFrame.origin.y = toolbar.frame.size.height;
	self.tableView.frame = tableFrame;
	
	self.allowsMultipleSelection = NO;
	self.itemPicturesEnabled = YES;
	self.sortOrdering = FBFriendSortByFirstName;
	self.displayOrdering = FBFriendDisplayByFirstName;
	self.doneButton = nil;
	self.cancelButton = nil;
	
	self.delegate = (id)self;
	self.spinner.hidesWhenStopped;
	[self loadFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriends
{
	[self.spinner startAnimating];
	self.tableView.hidden = YES;
	
	[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if(!error)
		{
			NSArray* friends = [result objectForKey:@"data"];
			NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friends.count];

			for (NSDictionary<FBGraphUser>* friend in friends)
			{
				//NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
				[friendIds addObject:friend.id];
			}
			
			PFQuery *patronQuery = [PFQuery queryWithClassName:@"Patron"];
			[patronQuery whereKey:@"facebook_id" containedIn:friendIds];
			[patronQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
			{
				if(!error)
				{
					for(PFObject *patron in results)
					{
						[self.friendDictionary setObject:patron.objectId forKey:[patron objectForKey:@"facebook_id"]];
						NSLog(@"patronid: %@, fbookId: %@", patron.objectId, [patron objectForKey:@"facebook_id"]);
					}
					[self loadData];
					self.tableView.hidden = NO;
				}
				else
				{
					//TODO
					NSLog(@"Error 1: %@", error);
					SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"(DEBUG) patron query fucked up"
																	 andMessage:error.localizedDescription];
					
					[alertView addButtonWithTitle:@"OK"
											 type:SIAlertViewButtonTypeDefault
										  handler:nil];
					[alertView show];
				}
				[self.spinner stopAnimating];
			}];
		}
		else
		{
			[self.spinner startAnimating];
			//TODO
			NSLog(@"Error 2: %@", error);
			NSLog(@"Error 1: %@", error);
			SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"(DEBUG) FBRequestConnection fucked up"
															 andMessage:error.localizedDescription];
			
			[alertView addButtonWithTitle:@"OK"
									 type:SIAlertViewButtonTypeDefault
								  handler:nil];
			[alertView show];
		}
	}];
}

// Event: Error during data fetch
- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error
{
	NSLog(@"Error during data fetch.");
}

// Event: Data loaded
- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    NSLog(@"Friend data loaded.");
	//friendpicker.
}

// Event: Decide if a given user should be displayed
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <FBGraphUser>)user
{
    return [self.friendDictionary objectForKey:user.id] ? YES : NO;
}

// Event: Selection changed
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
	
	NSDictionary<FBGraphUser> *selection = [friendPicker.selection objectAtIndex:0];
	NSString *recepientId = [self.friendDictionary objectForKey:selection.id];

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
