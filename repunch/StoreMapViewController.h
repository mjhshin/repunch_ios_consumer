//
//  PlacesDetailMapViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "MapPin.h"
#import "GradientBackground.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "RepunchUtils.h"

@interface StoreMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) NSString *storeId;

@end
