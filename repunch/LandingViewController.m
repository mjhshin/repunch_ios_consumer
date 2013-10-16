//
//  LandingViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LandingViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "GradientBackground.h"

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.loginButton]
								   forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.loginButton]
								   forState:UIControlStateHighlighted];
	[self.loginButton.layer setCornerRadius:5];
	[self.loginButton setClipsToBounds:YES];
	
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonNormal:self.registerButton]
						 forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[GradientBackground orangeButtonHighlighted:self.registerButton]
						 forState:UIControlStateHighlighted];
	[self.registerButton.layer setCornerRadius:5];
	[self.registerButton setClipsToBounds:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)registerButtonPress:(id)sender
{
	RegisterViewController *registerVC = [[RegisterViewController alloc] init];
	[self.navigationController pushViewController:registerVC animated:YES];
	
}

- (IBAction)loginButtonPress:(id)sender
{
	LoginViewController *loginVC = [[LoginViewController alloc] init];
	[self.navigationController pushViewController:loginVC animated:YES];
}

@end
