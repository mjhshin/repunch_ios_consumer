//
//  GlobalToolbar.h
//  repunch
//
//  Created by CambioLabs on 3/29/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalToolbar : UIToolbar
{
    UIViewController *delegate;
}

@property (nonatomic, retain) UIViewController *delegate;

@end
