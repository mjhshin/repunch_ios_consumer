//
//  PlacesDetailMapViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/25/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PlacesDetailMapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "MapPin.h"

@implementation PlacesDetailMapViewController

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
    [placeTitleLabel setText:[_place store_name]];
    [placeTitleLabel sizeToFit];
    
    UIBarButtonItem *placeTitleItem = [[UIBarButtonItem alloc] initWithCustomView:placeTitleLabel];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *directionsButton= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [directionsButton setTitle:@"Directions" forState:UIControlStateNormal];
    [directionsButton setFrame:CGRectMake(0, 0, 100, 40)];
    [directionsButton addTarget:self action:@selector(getWalkingDirections) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *directionButtonItem = [[UIBarButtonItem alloc] initWithCustomView:directionsButton];


    
    [placeToolbar setItems:[NSArray arrayWithObjects:closePlaceButtonItem, flex, placeTitleItem, flex2, directionButtonItem, nil]];
    [self.view addSubview:placeToolbar];
    
    MKMapView *placeMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, placeToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - placeToolbar.frame.size.height)];
    [placeMapView setCenterCoordinate:CLLocationCoordinate2DMake([_place latitude],[_place longitude]) zoomLevel:14 animated:NO];
    
    NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", [_place valueForKey:@"street"], [_place valueForKey:@"city"], [_place valueForKey:@"state"], [_place valueForKey:@"zip"]];

    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake([_place latitude], [_place longitude]) placeName:[_place store_name] description:addressString];
    
    [placeMapView addAnnotation:placePin];
    
    [self.view addSubview:placeMapView];

}
-(void)closePlaceMap
{
    [[self modalDelegate] didDismissPresentedViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getWalkingDirections{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake([_place latitude],[_place longitude]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:@"My Place"];
        
        // Set the directions mode to "Walking"
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }

}

@end
