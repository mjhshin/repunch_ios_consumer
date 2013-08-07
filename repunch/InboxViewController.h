//
//  InboxViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)openSettings:(id)sender;
- (IBAction)openSearch:(id)sender;
- (IBAction)showPunchCode:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
