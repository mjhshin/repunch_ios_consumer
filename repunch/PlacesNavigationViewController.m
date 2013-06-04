//
//  PlacesNavigationViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PlacesNavigationViewController.h"

@interface PlacesNavigationViewController ()

@end

@implementation PlacesNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"My Places", @"My Places");
        self.tabBarItem.image = [UIImage imageNamed:@"ico-tab-places"];
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

@end
