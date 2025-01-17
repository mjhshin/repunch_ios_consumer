//
//  InboxViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPTableView.h"
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "IncomingMessageViewController.h"
#import "InboxTableViewCell.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RPConstants.h"

@interface InboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IncomingMessageVCDelegate>

@property (weak, nonatomic) IBOutlet RPTableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyInboxLabel;

@end
