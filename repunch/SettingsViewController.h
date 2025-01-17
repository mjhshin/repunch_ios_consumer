//
//  SettingsViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 9/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPTableView.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet RPTableView *tableView;

@end
