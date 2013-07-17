//
//  PlacesDetailMapViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/25/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalDelegate.h"
#import "Store.h"

@interface PlacesDetailMapViewController : UIViewController
- (IBAction)closeView:(id)sender;
- (IBAction)getDirections:(id)sender;

@property (nonatomic, retain) Store *place;
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;

@end
