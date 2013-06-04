//
//  SettingsViewController.m
//  repunch
//
//  Created by CambioLabs on 3/29/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "SettingsViewController.h"
#import "LegalViewController.h"
#import "SettingsSortViewController.h"
#import "PlacesViewController.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize settingsTableView, notificationSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Settings";
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeButton addTarget:self action:@selector(closeSettings) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closeButton] autorelease];
    
    UIImage *settingsBackImage = [UIImage imageNamed:@"btn-back-settings"];
    UIImage *barBackBtnImg = [settingsBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    notificationSwitch = [[UISwitch alloc] init];
    [notificationSwitch addTarget:self action:@selector(setNotificationSetting) forControlEvents:UIControlEventValueChanged];
    
    settingsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    [settingsTableView setDelegate:self];
    [settingsTableView setDataSource:self];
    [self.view addSubview:settingsTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [settingsTableView reloadData];
}

- (void)closeSettings
{
    [(PlacesViewController *)self.navigationController.delegate closeSettings];
}

- (void)setNotificationSetting
{
    [[NSUserDefaults standardUserDefaults] setBool:notificationSwitch.on forKey:@"notification"];
    if (notificationSwitch.on) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    switch (section) {
        case 0:
            rows = 2;
            break;
            
        case 1:
            rows = 3;
            break;
            
        case 2:
            rows = 2;
            break;
            
        case 3:
            rows = 1;
            break;
    }
    
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    
    switch (section) {
        case 0:
            sectionTitle = @"App Settings";
            break;
            
        case 1:
            sectionTitle = @"Legal";
            break;
            
        case 2:
            sectionTitle = @"Information";
            break;
            
        case 3:
            sectionTitle = @"For testing";
            break;
    }
    
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    [self.notificationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"notification"]];
                    cell.accessoryView = self.notificationSwitch;
                    cell.textLabel.text = @"Enable notifications";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1:
                    cell.textLabel.text = @"Sort Retailers";
                    cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"sort"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
            }
            break;
            
        case 1:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Terms and Conditions";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Privacy Policy";
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Show Licenses";
                    break;
            }
            break;
        
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Version";
                    cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Log out";
                    PFUser *pfuser = [PFUser currentUser];
                    
                    NSString *loggedInAs = @"";
                    if ([pfuser objectForKey:@"first_name"] != nil && ![[pfuser objectForKey:@"first_name"] isEqualToString:@""]
                        && [pfuser objectForKey:@"last_name"] != nil && ![[pfuser objectForKey:@"last_name"] isEqualToString:@""])
                    {
                        loggedInAs = [NSString stringWithFormat:@"%@ %@",[pfuser objectForKey:@"first_name"],[pfuser objectForKey:@"last_name"]];
                    } else {
                        loggedInAs = [pfuser username];
                    }
                    
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Logged in as %@",loggedInAs];
                    break;
            }            
            break;
            
        case 3:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Delete user";
                    break;
            }
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    
                    break;
                
                case 1:{
                    SettingsSortViewController *ssvc = [[SettingsSortViewController alloc] init];
                    [self.navigationController pushViewController:ssvc animated:YES];
                    [ssvc release];
                    break;
                }
            }
            break;
            
        case 1:{
            LegalViewController *lvc = [[LegalViewController alloc] init];
            
            switch (indexPath.row) {
                case 0:
                    lvc.document = @"terms";
                    break;
                case 1:
                    lvc.document = @"privacy";
                    break;
                case 2:
                    lvc.document = @"licenses";
                    break;
            }            
            [self.navigationController pushViewController:lvc animated:YES];
            [lvc release];
            
            break;
        }
        case 2:
            if (indexPath.row == 1) {
                [PFUser logOut];
                
                AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                LandingViewController *landingVC = [[LandingViewController alloc] init];
                ad.lvc = landingVC;
                ad.window.rootViewController = ad.lvc;
                
                [self closeSettings];
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [[PFUser currentUser] delete];
                    
                    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    LandingViewController *landingVC = [[LandingViewController alloc] init];
                    ad.lvc = landingVC;
                    ad.window.rootViewController = ad.lvc;
                    
                    [self closeSettings];
                    
                    break;
            }
            break;            
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
