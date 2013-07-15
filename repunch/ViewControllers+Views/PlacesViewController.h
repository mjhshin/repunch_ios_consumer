//
//  PlacesViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface PlacesViewController : UIViewController< ModalDelegate, UITableViewDelegate, UITableViewDataSource>

- (IBAction)openSettings:(id)sender;
- (IBAction)showPunchCode:(id)sender;
- (IBAction)openSearch:(id)sender;

//Modal Delegate Methods
- (void)didDismissPresentedViewController;



@end
