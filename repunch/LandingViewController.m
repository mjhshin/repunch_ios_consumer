//
//  LandingViewController.m
//  repunch
//
//  Created by CambioLabs on 5/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "LandingViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface LandingViewController ()

@end

@implementation LandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"splash"]]];
    
    UIImage *logoImage = [UIImage imageNamed:@"repunch"];
    UIImageView *logoImageView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
    [logoImageView setFrame:CGRectMake(self.view.frame.size.width / 2 - logoImage.size.width / 2, self.view.frame.size.height / 3 - logoImage.size.height, logoImage.size.width, logoImage.size.height)];
    [self.view addSubview:logoImageView];
    
    UIImage *loginImage = [UIImage imageNamed:@"btn-signin"];
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(goLogin) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setFrame:CGRectMake(self.view.frame.size.width / 2 - loginImage.size.width / 2, logoImageView.frame.origin.y + logoImageView.frame.size.height + 20, loginImage.size.width, loginImage.size.height)];
    [loginButton setImage:loginImage forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
    
    UIImage *registerImage = [UIImage imageNamed:@"btn-create-account"];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton addTarget:self action:@selector(goRegister) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setFrame:CGRectMake(self.view.frame.size.width / 2 - registerImage.size.width / 2, loginButton.frame.origin.y + loginButton.frame.size.height + 10, registerImage.size.width, registerImage.size.height)];
    [registerButton setImage:registerImage forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
}

- (void)goRegister
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RegisterViewController *rvc = [[[RegisterViewController alloc] init] autorelease];
    [ad.window setRootViewController:rvc];
}

- (void)goLogin
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LoginViewController *lvc = [[[LoginViewController alloc] init] autorelease];
    [ad.window setRootViewController:lvc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
