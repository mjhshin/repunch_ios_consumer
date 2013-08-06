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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
	/*
	self.navigationController.navigationBarHidden = YES;
	
	CAGradientLayer *bgLayer3 = [GradientBackground orangeGradient];
	bgLayer3.frame = self.navigationController.navigationBar.bounds;
	[self.navigationController.navigationBar.layer insertSublayer:bgLayer3 atIndex:0];
	NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
	[titleBarAttributes setValue:[UIFont fontWithName:@"Avenir" size:16] forKey:UITextAttributeFont];
	[[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
	*/
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _loginButton.bounds;
	[_loginButton.layer insertSublayer:bgLayer atIndex:0];
	[_loginButton.layer setCornerRadius:5];
	[_loginButton setClipsToBounds:YES];
	
	CAGradientLayer *bgLayer2 = [GradientBackground orangeGradient];
	bgLayer2.frame = _registerButton.bounds;
	[_registerButton.layer insertSublayer:bgLayer2 atIndex:0];
	[_registerButton.layer setCornerRadius:5];
	[_registerButton setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)registerButtonPress:(id)sender
{
	RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self presentViewController:registerVC animated:YES completion:nil];
	//[self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)loginButtonPress:(id)sender
{
	LoginViewController *loginVC = [[LoginViewController alloc] init];
	[self presentViewController:loginVC animated:YES completion:nil];
	//[self.navigationController pushViewController:loginVC animated:YES];
}

@end
