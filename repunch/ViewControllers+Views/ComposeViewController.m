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
#import "PatronStore.h"
#import "CoreDataStore.h"

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
    if ([_messageType isEqualToString:@"Feedback"]){
        NSString *subject = ([[_subject text] length]>0)? [_subject text]:[NSString stringWithFormat:@"Feedback for %@", [_storeObject store_name]];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[localUser patronId], @"patron_id", [_storeObject objectId], @"store_id", [_body text], @"body", subject, @"subject", [localUser fullName], @"sender_name", nil];
        
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
    }
    if ([_messageType isEqualToString:@"Gift"]){
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        spinner.center = CGPointMake(160, 260);
        spinner.color = [UIColor blackColor];
        //spinner.transform = CGAffineTransformMakeScale(2, 2); //sorta violates apple aesthetics. do we care?
        [[self view] addSubview:spinner];
        
        [spinner startAnimating];        
        
        NSDictionary *functionArguments = [NSDictionary dictionaryWithObjectsAndKeys:[_recipient objectId], @"patron_id", [_storeObject objectId], @"store_id", nil];
        
        [PFCloud callFunctionInBackground: @"add_patronstore"
                           withParameters:functionArguments block:^(PFObject *patronStore, NSError *error) {
                               if (!error){
                                                                      
                                   NSDictionary *functionParameters = [NSDictionary dictionaryWithObjectsAndKeys:[_storeObject objectId], @"store_id", [localUser patronId], @"user_id", [localUser fullName], @"sender_name", [_subject text], @"subject", [_body text], @"body", [_recipient objectId], @"recepient_id", [_giftParameters valueForKey:@"gift_title"],@"gift_title", [_giftParameters valueForKey:@"gift_description"], @"gift_description", [_giftParameters valueForKey:@"gift_punches"], @"gift_punches", nil];
                                   
                                   [PFCloud callFunctionInBackground:@"send_gift" withParameters:functionParameters block:^(id object, NSError *error) {
                                       if (!error){
                                           [spinner stopAnimating];
                                           SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sent!" andMessage:[NSString stringWithFormat:@"You sent %@ to %@", [_giftParameters valueForKey:@"gift_title"], [_recipient valueForKey:@"first_name"]]];
                                           [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                               [[self modalDelegate] didDismissPresentedViewController];
                                           }];

                                       }
                                       else {
                                           [spinner stopAnimating];
                                           
                                           SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
                                           [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                           }];

                                           NSLog(@"%@", error);

                                       }
                                   }];
                               }
                               else {
                                   [spinner stopAnimating];
                                   
                                   SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
                                   [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                                   }];
                                   

                                   NSLog(@"%@", error);
                               }
                           }];
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
