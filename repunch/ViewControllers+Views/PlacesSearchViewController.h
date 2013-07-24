//
//  PlacesSearchViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"

@interface PlacesSearchViewController : UIViewController <UIScrollViewDelegate, ModalDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
- (IBAction)closeView:(id)sender;

-(void)setup;

@end
