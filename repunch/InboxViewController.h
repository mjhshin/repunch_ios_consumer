//
//  InboxViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)openSettings:(id)sender;
- (IBAction)openSearch:(id)sender;
- (IBAction)showPunchCode:(id)sender;
- (IBAction)refreshPage:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

@end
