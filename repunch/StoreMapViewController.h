//
//  PlacesDetailMapViewController.h
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreMapViewController : UIViewController

- (IBAction)closeView:(id)sender;
- (IBAction)getDirections:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *toolbar;

@end
