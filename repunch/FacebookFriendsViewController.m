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
	closeButton.showsTouchWhenHighlighted = YES;
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
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
	footer.backgroundColor = [UIColor clearColor];
	[self.tableView setTableFooterView:footer];
	
	self.allowsMultipleSelection = NO;
	self.itemPicturesEnabled = YES;
	self.sortOrdering = FBFriendSortByFirstName;
	self.displayOrdering = FBFriendDisplayByFirstName;
	self.doneButton = nil;
	self.cancelButton = nil;
	
	self.delegate = (id)self;
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat xCenter = screenRect.size.width/2;
	CGFloat yCenter = screenRect.size.height/2;
	CGFloat xOffset = self.spinnerView.frame.size.width/2;
	CGFloat yOffset = (self.spinnerView.frame.size.height - toolbar.frame.size.height)/2;
	CGRect spinnerFrame = self.spinnerView.frame;
	spinnerFrame.origin = CGPointMake(xCenter - xOffset, yCenter - yOffset);
	self.spinnerView.frame = spinnerFrame;
	
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
					self.spinner.hidden = YES;
				}
				else
				{
					self.spinnerView.hidden = YES;
					[self.mySpinner stopAnimating];
					
					[RepunchUtils showDefaultErrorMessage];
					[self dismissViewControllerAnimated:NO completion:nil];
				}
			}];
		}
		else
		{
			self.spinnerView.hidden = YES;
			[self.mySpinner stopAnimating];
			
			//TODO
			//NSLog(@"Error 2: %@", error);
			//NSLog(@"Error 1: %@", error);
			SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sorry, something went wrong" andMessage:nil];
			[alertView addButtonWithTitle:@"OK"
									 type:SIAlertViewButtonTypeDefault
								  handler:nil];
			[alertView show];
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
}

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
