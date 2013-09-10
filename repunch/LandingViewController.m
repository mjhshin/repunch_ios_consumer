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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)registerButtonPress:(id)sender
{
	//self.navigationController.navigationBarHidden = NO;
	RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self presentViewController:registerVC animated:YES completion:nil];
	//[self.navigationController pushViewController:registerVC animated:YES];
	
}

- (IBAction)loginButtonPress:(id)sender
{
	//self.navigationController.navigationBarHidden = NO;
	LoginViewController *loginVC = [[LoginViewController alloc] init];
	[self presentViewController:loginVC animated:YES completion:nil];
	//[self.navigationController pushViewController:loginVC animated:YES];
}
@end
