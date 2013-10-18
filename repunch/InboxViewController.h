//
//  InboxViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SearchViewController.h"
#import "SettingsViewController.h"
#import "IncomingMessageViewController.h"
#import "InboxTableViewCell.h"
#import "DataManager.h"
#import "SIAlertView.h"
#import "GradientBackground.h"
#import <Parse/Parse.h>

@interface InboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IncomingMessageVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *emptyInboxLabel;

@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, strong) DataManager *sharedData;
@property (nonatomic, strong) PFObject *patron;
@property (nonatomic, strong) NSMutableArray *messagesArray;

@end
