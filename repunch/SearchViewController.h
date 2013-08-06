//
//  PlacesSearchViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property BOOL downloadFromNetwork;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
- (IBAction)closeView:(id)sender;
-(void)setup;


@end
