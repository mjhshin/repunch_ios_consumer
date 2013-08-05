//
//  MyPlacesViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPlacesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (IBAction)openSettings:(id)sender;
- (IBAction)showPunchCode:(id)sender;
- (IBAction)openSearch:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

@end
