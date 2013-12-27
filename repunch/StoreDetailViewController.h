//
//  StoreDetailViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPStore.h"

@interface StoreDetailViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) RPStore *store;

@end
