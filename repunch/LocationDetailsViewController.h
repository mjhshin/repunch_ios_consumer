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
#import "RPAnnotation.h"
#import "RPStore.h"
#import "DataManager.h"
#import "RepunchUtils.h"
#import "RPPopupButton.h"

@interface LocationDetailsViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *storeLocationId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *otherLocationsButton;
@property (weak, nonatomic) IBOutlet UIButton *expandedMapExitButton;
@property (weak, nonatomic) IBOutlet RPPopupButton *expandedMapDirectionsButton;
@property (weak, nonatomic) IBOutlet UIView *expandedMapStatusBar;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *bottomDivider;

@property (weak, nonatomic) IBOutlet UIView *hoursView;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;

- (IBAction)bigMapExitButtonAction:(id)sender;
- (IBAction)bigMapDirectionsButtonAction:(id)sender;

- (IBAction)mapButtonAction:(id)sender;
- (IBAction)callButtonAction:(id)sender;
- (IBAction)otherLocationsButtonAction:(id)sender;
- (IBAction)mapTapGestureAction:(UITapGestureRecognizer *)sender;

@end

