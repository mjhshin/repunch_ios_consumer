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

@interface PlaceDetailMapViewController ()

@end

@implementation PlaceDetailMapViewController

@synthesize place, delegate;

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
    
    UIToolbar *placeToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)] autorelease];
    [placeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closePlaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closePlaceButton setImage:closeImage forState:UIControlStateNormal];
    [closePlaceButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closePlaceButton addTarget:self action:@selector(closePlaceMap) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closePlaceButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closePlaceButton] autorelease];
    
    UILabel *placeTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(closePlaceButton.frame.size.width, 0, placeToolbar.frame.size.width - closePlaceButton.frame.size.width - 25, placeToolbar.frame.size.height)] autorelease];
    [placeTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [placeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [placeTitleLabel setTextColor:[UIColor whiteColor]];
    [placeTitleLabel setText:[self.place name]];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel] autorelease];
    
    UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *flex2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, nil]];
    [self.view addSubview:placeToolbar];
    
    MKMapView *placeMapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, placeToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - placeToolbar.frame.size.height)] autorelease];
    [placeMapView setCenterCoordinate:CLLocationCoordinate2DMake([self.place.latitude doubleValue], [self.place.longitude doubleValue]) zoomLevel:14 animated:NO];
    
    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake([self.place.latitude doubleValue], [self.place.longitude doubleValue]) placeName:self.place.name description:self.place.address];
    
    [placeMapView addAnnotation:placePin];
    
    [self.view addSubview:placeMapView];
}

-(void)closePlaceMap
{
    [(PlaceDetailViewController *)self.delegate closePlaceMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
