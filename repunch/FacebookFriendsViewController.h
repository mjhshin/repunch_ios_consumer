//
//  RepunchFriendsViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 7/12/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSDictionary *giftParametersDict;
- (IBAction)closePage:(id)sender;

@end
