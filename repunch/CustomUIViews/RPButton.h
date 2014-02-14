//
//  RPButton.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPButton : UIButton

- (void)setEnabled;
- (void)setDisabled;
- (void)setTitle:(NSString *)text;
- (void)startSpinner;
- (void)stopSpinner;

@end
