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

@interface StoreMapViewController : UIViewController

@property (nonatomic, strong) NSString *storeId;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

- (IBAction)closeView:(id)sender;
- (IBAction)getDirections:(id)sender;

@end
