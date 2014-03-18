//
//  SearchViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 3/14/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTableViewController.h"
#import "SearchMapViewController.h"

@interface SearchViewController : UIViewController <SearchTableVCDelegate>

@property (strong, nonatomic) SearchTableViewController *tableViewController;
@property (strong, nonatomic) SearchMapViewController *mapViewController;

@end
