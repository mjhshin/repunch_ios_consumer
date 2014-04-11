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

@interface RPTabBarController () <UITabBarControllerDelegate>

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
	//_blankVC = [[UIViewController alloc] init];
	_punchVC = [[PunchViewController alloc] init];
	
	RPNavigationController *myPlacesNavController = [[RPNavigationController alloc] initWithRootViewController:myPlacesVC];
	RPNavigationController *inboxNavController = [[RPNavigationController alloc] initWithRootViewController:inboxVC];
	[RepunchUtils setupNavigationController:myPlacesNavController];
	[RepunchUtils setupNavigationController:inboxNavController];
	
	myPlacesNavController.tabBarItem.title = @"My Places";
	inboxNavController.tabBarItem.title = @"Inbox";
	
	myPlacesNavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(8.0f, 0.0f);
	inboxNavController.tabBarItem.titlePositionAdjustment = UIOffsetMake(-8.0f, 0.0f);
	
	myPlacesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_my_places"];
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
	UITabBarItem *item = [self.tabBar.items objectAtIndex:kPunchTabIndex];
	
	UIView *view = [item valueForKey:@"view"];
	CGPoint pointToSuperview = [self.tabBar.superview convertPoint:view.center fromView:self.tabBar];
	CGRect myRect = CGRectMake(pointToSuperview.x, pointToSuperview.y, 70.0f, 64.0f);
	
	_punchTabButton = [[UIButton alloc] initWithFrame:myRect];
	_punchTabButton.autoresizingMask =	UIViewAutoresizingFlexibleLeftMargin |
										UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin |
										UIViewAutoresizingFlexibleBottomMargin;
	
	_punchTabButton.layer.anchorPoint = CGPointMake(1, 1);
	_punchTabButton.layer.cornerRadius = 6;
	_punchTabButton.clipsToBounds = YES;
	
	[_punchTabButton setBackgroundImage:[UIImage imageNamed:@"orange_gradient_button"] forState:UIControlStateNormal];
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button"] forState:UIControlStateNormal];
	
	[_punchTabButton addTarget:nil action:@selector(punchButtonAction) forControlEvents:UIControlEventTouchUpInside];
	_punchTabButton.layer.zPosition = 1;
	
	[self.view addSubview:_punchTabButton];
}

- (void)punchButtonAction
{
	NSLog(@"z: %f", _punchTabButton.layer.zPosition);
	if(_punchViewControllerShowing) {
		[self disablePunch];
	}
	else {
		[self enablePunch];
	}
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if(viewController != _punchVC) {
		_selectedIndexBeforePunch = tabBarController.selectedIndex;
	}
	
	if(_punchViewControllerShowing) {
		[self disablePunch];
	}
	else {
		[self enablePunch];
	}
}

- (void)enablePunch
{
	NSLog(@"Open punchVC");
	self.selectedIndex = kPunchTabIndex;
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button_exit"] forState:UIControlStateNormal];
	_punchViewControllerShowing = YES;
	
	[_punchVC requestPunch];
}

- (void)disablePunch
{
	NSLog(@"Close punchVC");
	
	self.selectedIndex = _selectedIndexBeforePunch;
	[_punchTabButton setImage:[UIImage imageNamed:@"punch_button"] forState:UIControlStateNormal];
	_punchViewControllerShowing = NO;
	
	[_punchVC cancelPunchRequest];
}

@end
