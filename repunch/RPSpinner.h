//
//  ORVCSpinner.h
//  Spinner
//
//  Created by Emil on 1/17/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPSpinner : UIView

@property (nonatomic) CGFloat fillingPercent;
@property (nonatomic) BOOL hideWhenFinish;
@property (nonatomic, readonly) BOOL isAnimating;


- (void)startAnimating;
- (void)stopAnimating;


- (void)setImageNamed:(NSString*)imageName;

@end
