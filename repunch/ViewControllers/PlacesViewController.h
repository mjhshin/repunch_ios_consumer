//
//  PlacesViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalToolbar.h"
#import "ModalDelegate.h"

@interface PlacesViewController : UIViewController <GlobalToolbarDelegate, ModalDelegate>


//Global Toolbar Delegate Methods
- (void) openSettings;
- (void) closeSettings;

//Modal Delegate Methods
- (void)didDismissPresentedViewController;



@end
