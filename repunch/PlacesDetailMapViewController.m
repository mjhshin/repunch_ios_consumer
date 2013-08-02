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
#import "GradientBackground.h"

@implementation PlacesDetailMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MKMapView *placeMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 47, self.view.frame.size.width, self.view.frame.size.height - 47)];
    [placeMapView setCenterCoordinate:CLLocationCoordinate2DMake([_place latitude],[_place longitude]) zoomLevel:14 animated:NO];
    
    NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", [_place valueForKey:@"street"], [_place valueForKey:@"city"], [_place valueForKey:@"state"], [_place valueForKey:@"zip"]];

    MapPin *placePin = [[MapPin alloc] initWithCoordinates:CLLocationCoordinate2DMake([_place latitude], [_place longitude]) placeName:[_place store_name] description:addressString];
    
    [placeMapView addAnnotation:placePin];
    
    [self.view addSubview:placeMapView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeView:(id)sender {
    [[self modalDelegate] didDismissPresentedViewController];

}

- (IBAction)getDirections:(id)sender {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake([_place latitude],[_place longitude]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[_place store_name]];
        
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
