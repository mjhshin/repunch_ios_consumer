//
//  InboxViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface InboxViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, ModalDelegate>
- (IBAction)openSettings:(id)sender;
- (IBAction)openSearch:(id)sender;
- (IBAction)showPunchCode:(id)sender;

@end
