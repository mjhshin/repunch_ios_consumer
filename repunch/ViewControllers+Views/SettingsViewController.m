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
    
    //THIS IS A TOOLBAR
    //FROM HERE...
    UIToolbar *placeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(dismissPresentedViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closePlaceButton];
    
    UILabel *placeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)];
    [placeTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:@"Settings"];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, nil]];
    [self.view addSubview:placeToolbar];
    //... TO HERE.  END TOOLBAR.

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
    [[self modalDelegate] didDismissPresentedViewController];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate logout];

}

@end
