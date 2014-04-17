//
//  RPTabBarController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 4/9/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPTabBarController.h"
#import "MyPlacesViewController.h"
#import "InboxViewController.h"
#import "PunchViewController.h"

#define kPunchTabIndex 1

@interface RPTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL punchViewControllerShowing;
@property (assign, nonatomic) NSUInteger selectedIndexBeforePunch;
//@property (strong, nonatomic) UIViewController *blankVC;
@property (strong, nonatomic) PunchViewController *punchVC;
@property (strong, nonatomic) UIButton *punchTabButton;

@end

@implementation RPTabBarController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.delegate = self;
	
	_punchViewControllerShowing = NO;
	_selectedIndexBeforePunch = 0;
	
	MyPlacesViewController *myPlacesVC = [[MyPlacesViewController alloc] init];
	InboxViewController *inboxVC = [[InboxViewController alloc] init];
	_punchVC = [[PunchViewController alloc] init];
	
	RPNavigationController *myPlacesNavController = [[RPNavigationController alloc] initWithRootViewController:myPlacesVC];
	RPNavigationController *inboxNavController = [[RPNavigationController alloc] initWithRootViewController:inboxVC];
	[RepunchUtils setupNavigationController:myPlacesNavController];
	[RepunchUtils setupNavigationController:inboxNavController];
	myPlacesNavController.delegate = self;
	inboxNavController.delegate = self;
	
	myPlacesNavController.tabBarItem.title = @"My Places";
	myPlacesNavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(8.0f, 0.0f);
	myPlacesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_my_places"];
	
	inboxNavController.tabBarItem.title = @"Inbox";
	inboxNavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(-8.0f, 0.0f);
	inboxNavController.tabBarItem.image = [UIImage imageNamed:@"tab_inbox"];
	
	self.viewControllers = @[myPlacesNavController, _punchVC, inboxNavController];
	
	//pre-load inbox tab
	[inboxVC view];
	
	[self setupPunchButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(disablePunch)
												 name:@"PunchComplete"
											   object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//_punchTabButton.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	//_punchTabButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPunchButton
{
	_punchTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_punchTabButton.frame = CGRectMake(0.0f, 0.0f, 72.0f, 68.0f);
	_punchTabButton.center = self.tabBar.center;
	_punchTabButton.autoresizingMask =	UIViewAutoresizingFlexibleLeftMargin |
										UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin |
										UIViewAutoresizingFlexibleBottomMargin;
	
	_punchTabButton.layer.cornerRadius = 6;
	_punchTabButton.clipsToBounds = YES;
	
	[_punchTabButton setBackgroundImage:[UIImage imageNamed:@"orange_gradient_button"] forState:UIControlStateNormal];
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button"] forState:UIControlStateNormal];
	
	[_punchTabButton addTarget:self
						action:@selector(enablePunch)
			  forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:_punchTabButton];
}

- (void)hidePunchButton
{
	_punchTabButton.hidden = YES;
}

- (void)showPunchButton
{
	_punchTabButton.layer.zPosition = 1;
	_punchTabButton.hidden = NO;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSLog(@"Open index: %i", tabBarController.selectedIndex);
	if(tabBarController.selectedIndex != 1) {
		_selectedIndexBeforePunch = tabBarController.selectedIndex;
	}
	else {
		if(_punchViewControllerShowing) {
			[self disablePunch];
		}
		else {
			[self enablePunch];
		}
	}
}

- (void)enablePunch
{
	NSLog(@"Open punchVC");
	_punchViewControllerShowing = YES;
	
	self.selectedIndex = kPunchTabIndex;
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button_exit"] forState:UIControlStateNormal];
	
	[_punchVC requestPunch];
}

- (void)disablePunch
{
	NSLog(@"Close punchVC");
	_punchViewControllerShowing = NO;
	
	self.selectedIndex = _selectedIndexBeforePunch;
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button"] forState:UIControlStateNormal];
	
	[_punchVC cancelPunchRequest];
}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	if(navigationController.viewControllers.count > 1) {
		[self hidePunchButton];
	}
	else {
		[self showPunchButton];
	}
}

@end
