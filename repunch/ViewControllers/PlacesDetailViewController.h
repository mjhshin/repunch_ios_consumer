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

@interface PlacesDetailViewController : UIViewController<ModalDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) id<ModalDelegate> modalDelegate;
@property (nonatomic, retain) PFObject* storeObject;
@property (nonatomic, retain) NSData* storePic;
@property BOOL isSavedStore;
@end
