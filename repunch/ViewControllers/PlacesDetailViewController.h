//
//  PlacesDetailViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/19/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "ModalDelegate.h"
#import "Store.h"

@interface PlacesDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) Store* storeObject;
@property BOOL isSavedStore;
@end
