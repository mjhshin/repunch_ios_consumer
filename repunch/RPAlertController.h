//
//  RPAlertController.h
//  Repunch Biz
//
//  Created by Emil on 2/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPAlertController : UIViewController

@property id firstResponder;

- (void)showAlert;
- (void)showAsAction;
- (void)hideAlertWithBlock:(void (^) (void))block;

@end
