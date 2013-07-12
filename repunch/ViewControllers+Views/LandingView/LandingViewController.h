//
//  LandingViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/11/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface LandingViewController : UIViewController <ModalDelegate>
- (IBAction)signIn:(id)sender;
- (IBAction)registerUser:(id)sender;

//Modal Delegate Methods
- (void)didDismissPresentedViewController;


@end
