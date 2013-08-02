//
//  ComposeViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/27/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "GradientBackground.h"

#include <Parse/Parse.h>

@implementation ComposeViewController
{
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

    _storeName.text = [_storeObject valueForKey:@"store_name"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _body.delegate = self;
    
    if ([_messageType isEqualToString:@"Feedback"]){
        _subject.placeholder = [NSString stringWithFormat:@"Feedback for %@", [_storeObject store_name]];
    }
	
    if ([_messageType isEqualToString:@"Gift"]){
        _subject.placeholder = [NSString stringWithFormat:@"Gift for %@", [_recipient valueForKey:@"first_name"]];
        _instructionLabel.hidden = YES;
    }
    
    if ([_messageType isEqualToString:@"GiftReply"]){
        _subject.placeholder = [NSString stringWithFormat:@"Thanks for the gift!"];
        _instructionLabel.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
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
    /*
    UIView *greyedOutView = [[UIView alloc]initWithFrame:CGRectMake(0, 47, 320, self.view.frame.size.height - 47)];
    [greyedOutView setBackgroundColor:[UIColor colorWithRed:127/255 green:127/255 blue:127/255 alpha:0.5]];
    [[self view] addSubview:greyedOutView];
    [[self view] bringSubviewToFront:greyedOutView];
     */
    
    if ([_messageType isEqualToString:@"Feedback"]){
        NSString *subject = ([[_subject text] length]>0)? [_subject text]:[NSString stringWithFormat:@"Feedback for %@", [_storeObject store_name]];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[localUser patronId], @"patron_id", [_storeObject objectId], @"store_id", [_body text], @"body", subject, @"subject", [localUser fullName], @"sender_name", nil];
        
        [PFCloud callFunctionInBackground:@"send_feedback" withParameters:dictionary block:^(NSString *result, NSError *error) {
            if (!error){
                /*
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sent!" andMessage:@"Your feedback was sent."];
                
                [alertView addButtonWithTitle:@"Ok."
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          [[self modalDelegate] didDismissPresentedViewController];
                                      }];
                [alertView show];
                NSLog(@"result is: %@", result);
                 */
            }
            else NSLog(@"error occured: %@", error);
            
        }];
        [[self modalDelegate] didDismissPresentedViewController];

    }
    if ([_messageType isEqualToString:@"Gift"]){
        /*
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        spinner.center = CGPointMake(160, 260);
        spinner.color = [UIColor blackColor];
        [[self view] addSubview:spinner];
        
        [spinner startAnimating];
         */
        
        NSString *subjectText = ([[_subject text] length]>0)? [_subject text] : [NSString stringWithFormat:@"Gift for %@", [_recipient valueForKey:@"first_name"]];
                                          
        NSDictionary *functionParameters = [NSDictionary dictionaryWithObjectsAndKeys:[_sendParameters valueForKey:@"store_id"], @"store_id", [_sendParameters valueForKey:@"patron_store_id"], @"patron_store_id", [localUser patronId], @"patron_id", [localUser fullName], @"sender_name", subjectText, @"subject", [_body text], @"body", [_recipient objectId], @"recepient_id", [_sendParameters valueForKey:@"gift_title"],@"gift_title", [_sendParameters valueForKey:@"gift_description"], @"gift_description", [_sendParameters valueForKey:@"gift_punches"], @"gift_punches", nil];

        [PFCloud callFunctionInBackground:@"send_gift" withParameters:functionParameters block:^(id object, NSError *error) {
           if (!error){
               /*
               [spinner stopAnimating];
               [greyedOutView removeFromSuperview];
               
               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sent!" andMessage:[NSString stringWithFormat:@"You sent %@ to %@", [_sendParameters valueForKey:@"gift_title"], [_recipient valueForKey:@"first_name"]]];
               [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                   [[self modalDelegate] didDismissPresentedViewController];
               }];
               
               [alertView show];
                */

           }
           else {
               /*
               [spinner stopAnimating];
               [greyedOutView removeFromSuperview];
               
               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
               [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
               }];

               NSLog(@"%@", error);
               
               [alertView show];
                */


           }
        }];
        [[self modalDelegate] didDismissPresentedViewController];

    }
    
    if ([_messageType isEqualToString:@"GiftReply"]){

        NSDictionary *functionParameters = [[NSDictionary alloc] initWithObjectsAndKeys:[_sendParameters valueForKey:@"message_id"], @"message_id", [localUser patronId], @"patron_id", [localUser fullName], @"sender_name", [_body text], @"body", nil];
        
        [PFCloud callFunctionInBackground:@"reply_to_gift" withParameters:functionParameters block:^(id object, NSError *error) {
            //
        }];
        [[self modalDelegate] didDismissPresentedViewController];

    }

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
