//
//  SettingsViewController.m
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/13/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@implementation SettingsViewController

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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    _currentLogin.text = [NSString stringWithFormat:@"You are currently logged is as %@", _userName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)termsAndConditions:(id)sender {
}

- (IBAction)privacyPolicy:(id)sender {
}

- (IBAction)logOut:(id)sender {
    [[self modalDelegate] didDismissPresentedViewControllerWithCompletion];
}

- (IBAction)closeView:(id)sender {
    [self dismissPresentedViewController];
}

-(void)dismissPresentedViewController {
    [[self modalDelegate] didDismissPresentedViewController];
}

@end
