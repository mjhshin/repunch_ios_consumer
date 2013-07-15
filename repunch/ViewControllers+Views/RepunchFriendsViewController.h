//
//  RepunchFriendsViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface RepunchFriendsViewController : UIViewController <ModalDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) NSDictionary *giftParametersDict;
- (IBAction)closePage:(id)sender;
@end
