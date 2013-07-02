//
//  UIViewController+animateView.h
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

@interface UIViewController (animateView)

- (void) animateView: (UIView*) myView up:(BOOL)up distance:(int)distance completion:(void (^)(BOOL finished))completion;

@end
