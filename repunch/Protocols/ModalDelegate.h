//
//  ModalDelegate.h
//  repunch_two
//
//  Created by Gwendolyn Weston on 6/10/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModalDelegate <NSObject>
- (void)didDismissPresentedViewController;
- (void)didDismissPresentedViewControllerWithCompletion;

@end
