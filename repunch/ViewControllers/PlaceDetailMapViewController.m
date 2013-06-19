//
//  PlaceDetailMapViewController.m
//  repunch
//
//  Created by CambioLabs on 3/28/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PlaceDetailMapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "MapPin.h"
#import "PlaceDetailViewController.h"

@implementation PlaceDetailMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *placeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(closePlaceMap) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closePlaceButton];
    
    UILabel *placeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)];
    [placeTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:_place.store_name];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, nil]];
    [self.view addSubview:placeToolbar];
    
    MKMapView *placeMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, placeToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - placeToolbar.frame.size.height)];
    [placeMapView setCenterCoordinate:CLLocationCoordinate2DMake(_place.longitude, _place.latitude) zoomLevel:14 animated:NO];
    
    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake(_place.longitude, _place.latitude) placeName:_place.store_name description:_place.street];
    
    [placeMapView addAnnotation:placePin];
    
    [self.view addSubview:placeMapView];
}

-(void)closePlaceMap
{
    [[self modalDelegate] didDismissPresentedViewController];
}


@end
