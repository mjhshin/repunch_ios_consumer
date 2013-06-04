//
//  SettingsViewController.h
//  repunch
//
//  Created by CambioLabs on 3/29/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *settingsTableView;
    UISwitch *notificationSwitch;
}

@property (nonatomic, retain) UITableView *settingsTableView;
@property (nonatomic, retain) UISwitch *notificationSwitch;

@end
