//
//  LandingViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "LandingViewController.h"
#import "SignInViewController.h"
#import "RegisterViewController.h"

#import "UIViewController+KNSemiModal.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation LandingViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)signIn:(id)sender {
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    signInVC.modalDelegate = self;
    [self presentSemiViewController:signInVC withOptions:@{
         KNSemiModalOptionKeys.pushParentBack : @(NO),
         KNSemiModalOptionKeys.parentAlpha : @(0.8)
	 }];
    
}

- (IBAction)registerUser:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.modalDelegate = self;
    [self presentSemiViewController:registerVC withOptions:@{
         KNSemiModalOptionKeys.pushParentBack : @(NO),
         KNSemiModalOptionKeys.parentAlpha : @(0.8)
	 }];

}

#pragma mark - modal delegate views

-(void)didDismissPresentedViewController {
    [self dismissSemiModalView];
}

-(void)didDismissPresentedViewControllerWithCompletion {
    [self dismissSemiModalViewWithCompletion:^{
        //go to saved places view
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate login];

    }];
}

#pragma mark - text field delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if ([[alertView title] isEqualToString:@"Forgotten password?"]){
            NSString *email = [[alertView textFieldAtIndex:0] text];
            [PFUser requestPasswordResetForEmailInBackground:email];
        }
    }
}

@end
