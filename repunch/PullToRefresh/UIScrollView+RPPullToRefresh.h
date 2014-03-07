//
//  UIScrollView+RPPulltoRefresh.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPActivityIndicatorView.h"

@interface UIScrollView (RPActivityIndicatorView)

@property (nonatomic,assign) BOOL showPullToRefresh;
@property (nonatomic,strong,readonly) RPActivityIndicatorView *pullToRefreshView;

- (void)addPullToRefreshActionHandler:(actionHandler)handler;
- (void)triggerPullToRefresh;
- (void)stopRefreshAnimation;

@end
