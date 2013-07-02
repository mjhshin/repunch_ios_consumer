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
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, nil]];
    [self.view addSubview:placeToolbar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _body.delegate = self;


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
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[localUser patronId], @"patron_id", [_storeObject objectId], @"store_id", [_body text], @"body", [_subject text], @"subject", [localUser first_name], @"sender_name", nil];
        
        [PFCloud callFunctionInBackground:@"send_feedback" withParameters:dictionary block:^(NSString *result, NSError *error) {
            if (!error){
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sent!" andMessage:@"Your feedback was sent."];
                
                [alertView addButtonWithTitle:@"Ok."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          [[self modalDelegate] didDismissPresentedViewController];
                                      }];
                [alertView show];
                NSLog(@"result is: %@", result);
            }
            else NSLog(@"error occured: %@", error);
            
        }];

        return NO;
    }
    return YES;
}

-(void)closeView{
    [[self modalDelegate] didDismissPresentedViewController];
}

-(void)dismissKeyboard {
    [_subject resignFirstResponder];
    [_body resignFirstResponder];
    
}

@end
