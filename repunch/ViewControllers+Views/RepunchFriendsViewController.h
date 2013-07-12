//
//  RepunchFriendsViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface RepunchFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closePage;
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;

@end
