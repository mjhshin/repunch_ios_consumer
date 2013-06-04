//
//  LegalViewController.m
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "LegalViewController.h"

@interface LegalViewController ()

@end

@implementation LegalViewController

@synthesize document, legalWebView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    legalWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:legalWebView];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.document isEqualToString:@"privacy"]) {
        self.navigationItem.title = @"Privacy Policy";
    } else if([self.document isEqualToString:@"licenses"]) {
        self.navigationItem.title = @"Licenses";
    } else {
        // Terms
        self.document = @"terms";
        self.navigationItem.title = @"Terms and Conditions";
    }
    
    [self.legalWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.document ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
