//
//  ComposeViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "ComposeViewController.h"
#import "Store.h"
#import "User.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "CustomToolbar.h"

#include <Parse/Parse.h>
//TODO DATA VALIDATION FOR ALL FIELDS

@implementation ComposeViewController{
    User *localUser;
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
    /*
    UIToolbar *placeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closePlaceButton];
    
    UILabel *placeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)];
    [placeTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:[_storeObject valueForKey:@"store_name"]];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [[sendButton titleLabel] setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    [sendButton setFrame:CGRectMake(0, 0, 100, 50)];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, sendButtonItem, nil]];
    [self.view addSubview:placeToolbar];
     */
    
    _storeName.text = [_storeObject valueForKey:@"store_name"];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _body.delegate = self;
    
    _subject.placeholder = [NSString stringWithFormat:@"Feedback for %@", [_storeObject store_name]];


}

-(void)viewWillAppear:(BOOL)animated {
    localUser = [(AppDelegate *)[[UIApplication sharedApplication] delegate] localUser];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) textView: (UITextView*) textView
shouldChangeTextInRange: (NSRange) range
  replacementText: (NSString*) text
{
    if ([text isEqualToString:@"\n"]) {
        [self dismissKeyboard];
        [self sendMessage];

        return NO;
    }
    return YES;
}

-(void)sendMessage{


    
}

-(void)closeView{
    [[self modalDelegate] didDismissPresentedViewController];
}

-(void)dismissKeyboard {
    [_subject resignFirstResponder];
    [_body resignFirstResponder];
    
}

- (IBAction)sendFeedback:(id)sender {
    [self sendMessage];
}

- (IBAction)closeButton:(id)sender {
    [self closeView];

}
@end
