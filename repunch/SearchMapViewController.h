//
//  SearchMapViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 3/13/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MKMapView+ZoomLevel.h"

@interface SearchMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSArray *storeLocationIdArray;
@property (strong, nonatomic) PFGeoPoint *userLocation;

- (void)refreshMapView;

@end
