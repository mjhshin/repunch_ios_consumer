//
//  PlaceDetailMapViewController.h
//  repunch
//
//  Created by CambioLabs on 3/28/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Retailer.h"

@interface PlaceDetailMapViewController : UIViewController{
    Retailer *place;
    UIViewController *delegate;
}

@property (nonatomic, retain) Retailer *place;
@property (nonatomic, retain) UIViewController *delegate;

@end
