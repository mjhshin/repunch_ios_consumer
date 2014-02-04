//
//  LocationViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 12/30/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPStoreLocation.h"
#import "MKMapView+ZoomLevel.h"
#import "MapPin.h"
#import "RPStore.h"
#import "DataManager.h"

@interface LocationDetailsViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) RPStoreLocation *storeLocation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *expandedMapExitButton;
@property (weak, nonatomic) IBOutlet UIButton *expandedMapDirectionsButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *expandedMapStatusBar;

- (IBAction)bigMapExitButtonAction:(id)sender;
- (IBAction)bigMapDirectionsButtonAction:(id)sender;

- (IBAction)mapButtonAction:(id)sender;
- (IBAction)callButtonAction:(id)sender;

@end
