//
//  UIViewController+animateView.m
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "UIViewController+animateView.h"

@implementation UIViewController (animateView)

- (void) animateView: (UIView*) myView up:(BOOL)up distance:(int)distance completion:(void (^)(BOOL finished))completion
{
    const int movementDistance = distance;
    const float movementDuration = 0.4f;
	
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:movementDuration
                     animations:^{
                         myView.frame = CGRectOffset(myView.frame, 0, movement);
                     }
                     completion:completion];
}

@end
