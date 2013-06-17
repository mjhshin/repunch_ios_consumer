//
//  PlacesViewController.h
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalToolbar.h"

@interface PlacesViewController : UIViewController <GlobalToolbarDelegate>


//Global Toolbar Delegate Methods
- (void)closePlaceDetail;
- (void)closeSettings;
- (void)sortPlaces;
- (void)loadPlaces;


@end
