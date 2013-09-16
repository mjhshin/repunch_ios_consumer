//
//  SettingsViewController.h
//	Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *toolbar;

- (IBAction)termsAndConditions:(id)sender;
- (IBAction)privacyPolicy:(id)sender;
- (IBAction)logOut:(id)sender;
- (IBAction)closeView:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UILabel *currentLogin;
@end
