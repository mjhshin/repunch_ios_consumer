//
//  PlacesDetailMapViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "MapPin.h"
#import <Parse/Parse.h>
#import "RepunchUtils.h"
#import "RPStoreLocation.h"

@interface StoreMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) RPStoreLocation *storeLocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
