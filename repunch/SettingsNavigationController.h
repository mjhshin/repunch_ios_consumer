//
//  SettingsNavigationController.h
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsNavigationController : UINavigationController
{
    UIViewController *delegate;
}

@property (nonatomic, retain) UIViewController *delegate;

@end
