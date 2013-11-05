//
//  LandingViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LandingViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "RepunchUtils.h"

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[RepunchUtils setDefaultButtonStyle:self.registerButton];
	[RepunchUtils setDefaultButtonStyle:self.loginButton];
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
