//
//  SettingsViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "SharedData.h"

@implementation SettingsViewController
{
	SharedData *sharedData;
}

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
	
	sharedData = [SharedData init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
    
	PFObject* patron = [sharedData patron];
	NSString* str1 = @"Logged in as ";
	NSString* firstName = [patron objectForKey:@"first_name"];
	NSString* str2 = @" ";
	NSString* lastName = [patron objectForKey:@"last_name"];
	
    _currentLogin.text = [NSString stringWithFormat:@"%@%@%@%@", str1, firstName, str2, lastName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)termsAndConditions:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.repunch.com/terms-mobile"]];
}

- (IBAction)privacyPolicy:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.repunch.com/privacy-mobile"]];
}

- (IBAction)logOut:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
