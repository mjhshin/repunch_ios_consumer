//
//  RPTabBarViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 4/21/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPTabBarViewController.h"
#import "MyPlacesViewController.h"
#import "InboxViewController.h"
#import "PunchViewController.h"
#import "RepunchUtils.h"
#import "RPNavigationController.h"
#import "UIImage+ImageEffects.h"
#import "RPPunchButton.h"

#define kTabBarHeight 50.0f
#define kPunchButtonWidth 80.0f
#define kPunchButtonHeight 50.0f

#define kPunchButtonAnimationDelay 0.0f
#define kPunchButtonAnimationDuration 0.2f
#define kTabBarAnimationDuration 0.1f

#define kBlackColorSelected 0.1f
#define kBlackColorUnselected 0.2f
#define kPunchBackgroundColor 0.3f
#define kPunchBackgroundAlpha 0.2f

@interface RPTabBarViewController () <UINavigationControllerDelegate>

@property (assign, nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIView *tabBarView;
@property (strong, nonatomic) UIButton *myPlacesButton;
@property (strong, nonatomic) UIButton *inboxButton;
@property (strong, nonatomic) UIButton *punchButton;

@end

@implementation RPTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self initChildViewControllers];
		[self initTabBarView];
    }
    return self;
}

- (void)initTabBarView
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	
	CGFloat tabButtonWidth = (screenWidth - kPunchButtonWidth)/2;
	
	_tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, screenHeight - kTabBarHeight, screenWidth, kTabBarHeight)];
	_tabBarView.layer.zPosition = MAXFLOAT; //needed?
	_tabBarView.clipsToBounds = NO;
	
	_myPlacesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_inboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_punchButton = [[RPPunchButton alloc] initWithFrame:CGRectMake(tabButtonWidth, 0.0f, kPunchButtonWidth, kPunchButtonHeight)];
	
	//[_punchButton setImage:[UIImage imageNamed:@"tab_punch"] forState:UIControlStateNormal];
	//[_punchButton setBackgroundImage:[UIImage imageNamed:@"new_orange_button"] forState:UIControlStateNormal];
	//[_punchButton setBackgroundImage:[UIImage imageNamed:@"new_orange_button"] forState:UIControlStateHighlighted];

	_myPlacesButton.frame = CGRectMake(0.0f, 0.0f, tabButtonWidth, kTabBarHeight);
	_inboxButton.frame = CGRectMake(screenWidth - tabButtonWidth, 0.0f, tabButtonWidth, kTabBarHeight);
	//_punchButton.frame = CGRectMake(tabButtonWidth, 0.0f, kPunchButtonWidth, kPunchButtonHeight);
	
	[_myPlacesButton addTarget:self
					   action:@selector(myPlacesTabSelected)
			 forControlEvents:UIControlEventTouchDown];
	
	[_inboxButton addTarget:self
					action:@selector(inboxTabSelected)
		  forControlEvents:UIControlEventTouchDown];
	
	[_punchButton addTarget:self
					action:@selector(punchButtonAction)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[_tabBarView addSubview:_myPlacesButton];
	[_tabBarView addSubview:_inboxButton];
	[_tabBarView addSubview:_punchButton];
	
	[self setTabSelectedView:_selectedIndex];
	
	[self.view addSubview:_tabBarView];
}

- (void)initChildViewControllers
{
	_selectedIndex = 0;
	
	MyPlacesViewController *myPlacesVC = [[MyPlacesViewController alloc] init];
	InboxViewController *inboxVC = [[InboxViewController alloc] init];
	
	RPNavigationController *myPlacesNavController = [[RPNavigationController alloc] initWithRootViewController:myPlacesVC];
	RPNavigationController *inboxNavController = [[RPNavigationController alloc] initWithRootViewController:inboxVC];
	[RepunchUtils setupNavigationController:myPlacesNavController];
	[RepunchUtils setupNavigationController:inboxNavController];
	myPlacesNavController.delegate = self;
	inboxNavController.delegate = self;
	
	_viewControllers = @[myPlacesNavController, inboxNavController];
	
	[self addChildViewController:myPlacesNavController];
	[self addChildViewController:inboxNavController];
	[self.view addSubview:myPlacesNavController.view];
	[inboxVC view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)myPlacesTabSelected
{
	[self setTabSelected:0];
}

- (void)inboxTabSelected
{
	[self setTabSelected:1];
}

- (void)setTabSelected:(NSUInteger)newSelectedIndex
{
	if(_selectedIndex == newSelectedIndex) {
		return;
	}
	
	_tabBarView.userInteractionEnabled = NO;
	
	[self setTabSelectedView:newSelectedIndex];
	
	id oldVC = _viewControllers[_selectedIndex];
	id newVC = _viewControllers[newSelectedIndex];
	
	[oldVC willMoveToParentViewController:self];
    [self addChildViewController:newVC];
	
	[self transitionFromViewController:oldVC
					  toViewController:newVC
							  duration:0.1
							   options:UIViewAnimationOptionTransitionCrossDissolve
							animations:^{}
							completion:^(BOOL finished) {
								[oldVC removeFromParentViewController];
								[newVC didMoveToParentViewController:self];
								[self.view bringSubviewToFront:_tabBarView];
								
								_selectedIndex = newSelectedIndex;
								_tabBarView.userInteractionEnabled = YES;
							}];
}

- (void)setTabSelectedView:(NSUInteger)newSelectedIndex
{
	if(newSelectedIndex == 0) {
		_myPlacesButton.backgroundColor = [UIColor colorWithWhite:kBlackColorSelected alpha:1.0f];
		_inboxButton.backgroundColor = [UIColor colorWithWhite:kBlackColorUnselected alpha:1.0f];
		[_myPlacesButton setImage:[UIImage imageNamed:@"tab_my_places"] forState:UIControlStateNormal];
		[_inboxButton setImage:[UIImage imageNamed:@"tab_inbox_gray"] forState:UIControlStateNormal];
	}
	else {
		_myPlacesButton.backgroundColor = [UIColor colorWithWhite:kBlackColorUnselected alpha:1.0f];
		_inboxButton.backgroundColor = [UIColor colorWithWhite:kBlackColorSelected alpha:1.0f];
		[_myPlacesButton setImage:[UIImage imageNamed:@"tab_my_places_gray"] forState:UIControlStateNormal];
		[_inboxButton setImage:[UIImage imageNamed:@"tab_inbox"] forState:UIControlStateNormal];
	}
}

- (void)punchButtonAction
{
	PunchViewController *punchVC = [[PunchViewController alloc] init];
	punchVC.backgroundImageView = [RepunchUtils blurredImageFromView:self.view];
	[self presentViewController:punchVC animated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	if(navigationController.viewControllers.count > 1 && !_tabBarView.hidden) {
		_tabBarView.hidden = YES;
		
		CGRect frame = _tabBarView.frame;
		frame.origin.y += kTabBarHeight;
		_tabBarView.frame = frame;
	}
}

- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	if(navigationController.viewControllers.count == 1 && _tabBarView.hidden) {
		_tabBarView.hidden = NO;
		
		[UIView animateWithDuration:kTabBarAnimationDuration
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 CGRect frame = _tabBarView.frame;
							 frame.origin.y -= kTabBarHeight;
							 _tabBarView.frame = frame;
						 }
						 completion:nil];
	}
}

@end
