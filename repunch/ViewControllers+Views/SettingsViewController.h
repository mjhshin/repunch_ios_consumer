//
//  SettingsViewController.h
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/13/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) NSString *userName;

- (IBAction)termsAndConditions:(id)sender;
- (IBAction)privacyPolicy:(id)sender;
- (IBAction)logOut:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *currentLogin;
@end
