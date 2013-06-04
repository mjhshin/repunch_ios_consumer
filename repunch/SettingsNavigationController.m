//
//  SettingsNavigationController.m
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "SettingsNavigationController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsNavigationController ()

@end

@implementation SettingsNavigationController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    [svc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self setViewControllers:[NSArray arrayWithObject:svc]];
    [svc release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad makeTabBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad makeTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
