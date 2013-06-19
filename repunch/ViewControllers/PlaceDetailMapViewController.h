//
//  PlaceDetailMapViewController.h
//  repunch
//
//  Created by CambioLabs on 3/28/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Store.h"

#import "ModalDelegate.h"

@interface PlaceDetailMapViewController : UIViewController

@property (nonatomic, retain) Store *place;
@property (nonatomic, retain) id<ModalDelegate> modalDelegate;

@end
