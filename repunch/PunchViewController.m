//
//  PunchViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PunchViewController.h"
#import "Retailer.h"
#import "User.h"
#import <Parse/Parse.h>

@interface PunchViewController ()

@end

@implementation PunchViewController

@synthesize bumpDiagram, bumpIsConnected;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Punch", @"Punch");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-punch-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-punch"]];
        self.bumpIsConnected = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    int instructionHeight = 90;
    UIView *bumpInstructions = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - instructionHeight - 49, self.view.frame.size.width, instructionHeight)] autorelease];
    [bumpInstructions setBackgroundColor:[UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1]];
    [self.view addSubview:bumpInstructions];
    
    bumpDiagram = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - bumpInstructions.frame.size.height - 49)];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFit];
    [bumpDiagram setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"bump_diagram2"], [UIImage imageNamed:@"bump_diagram"], nil]];
    [bumpDiagram setAnimationDuration:3.0];
//    [bumpDiagram setBackgroundColor:[UIColor colorWithRed:.5 green:0 blue:0 alpha:.5]];
    [self.view addSubview:bumpDiagram];
    
    UIImageView *bumpInfoIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico-info"]] autorelease];
    [bumpInfoIcon setFrame:CGRectMake(20, instructionHeight / 2 - 35/2, 35, 35)];
    [bumpInfoIcon setContentMode:UIViewContentModeScaleAspectFit];
    [bumpInstructions addSubview:bumpInfoIcon];
    
    UILabel *bumpInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(75, 2, self.view.frame.size.width - 85, instructionHeight - 40)] autorelease];
    [bumpInfoLabel setNumberOfLines:0];
    [bumpInfoLabel setText:@"Gently bump the cashier's device to get punched. Ask the cashier if you have any questions!"];
    [bumpInfoLabel sizeToFit];
    [bumpInfoLabel setBackgroundColor:[UIColor clearColor]];
    [bumpInfoLabel setTextColor:[UIColor colorWithRed:107/255.f green:109/255.f blue:107/255.f alpha:1]];
    [bumpInstructions addSubview:bumpInfoLabel];
    
    UIButton *bumpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bumpButton setFrame:CGRectMake(0, 0, 60, 40)];
    [bumpButton setTitle:@"Bump" forState:UIControlStateNormal];
    [bumpButton addTarget:self action:@selector(doBump) forControlEvents:UIControlEventTouchUpInside];
#if TARGET_IPHONE_SIMULATOR
//    [self.view addSubview:bumpButton];
#endif
    
}

- (void)viewDidAppear:(BOOL)animated
{
  }

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
