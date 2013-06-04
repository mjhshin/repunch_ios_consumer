//
//  InboxNavigationController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "InboxNavigationController.h"

@interface InboxNavigationController ()

@end

@implementation InboxNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Inbox", @"Inbox");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-inbox-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-inbox"]];
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
