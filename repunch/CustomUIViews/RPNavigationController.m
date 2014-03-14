//
//  RPNavigationController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPNavigationController.h"
#import "RepunchUtils.h"

@interface RPNavigationController ()

@end

@implementation RPNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																					   style:UIBarButtonItemStylePlain
																					  target:nil
																					  action:nil];
	[super pushViewController:viewController animated:animated];
}
/*

- (void)displayConnectionError
{
	[self displayMessage:@"No Internet Connection"];
}

- (void)displayMessage:(NSString *)message
{
	UILabel *dropdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	dropdownLabel.text = message;
	dropdownLabel.font = [RepunchUtils repunchFontWithSize:17 isBold:YES];
	dropdownLabel.textAlignment = NSTextAlignmentCenter;
	dropdownLabel.textColor = [UIColor whiteColor];
	dropdownLabel.backgroundColor = [UIColor colorWithRed:(0.9) green:(0.0) blue:(0.0) alpha:1.0]; //[UIColor redColor];
	[self.topViewController.view addSubview:dropdownLabel];
	
	CGRect rect = dropdownLabel.frame;
    rect.origin.y = 0;
	dropdownLabel.frame = rect;
	
	// Fade out the view right away
    [UIView animateWithDuration:0.25
						  delay: 0.0
						options: UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect2 = dropdownLabel.frame;
						 rect2.origin.y = 64;
						 dropdownLabel.frame = rect2;
					 }
					 completion:^(BOOL finished) {
						 // Wait one second and then fade in the view
						 [UIView animateWithDuration:0.25
											   delay: 1.0
											 options:UIViewAnimationOptionCurveEaseOut
										  animations:^{
											  CGRect rect3 = dropdownLabel.frame;
											  rect3.origin.y = 0;
											  dropdownLabel.frame = rect3;
										  }
										  completion:^(BOOL finished) {
											  [dropdownLabel removeFromSuperview];
										  }];
					 }];
}
*/ 

@end
