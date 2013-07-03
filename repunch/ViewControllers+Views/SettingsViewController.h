//
//  SettingsViewController.h
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/13/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface SettingsViewController : UIViewController

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;

- (IBAction)logOut:(id)sender;
- (IBAction)goBack:(id)sender;

@end
