//
//  RPTableView.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPPullToRefreshView.h"

@interface RPTableView : UITableView

@property (strong, nonatomic) UIView *defaultFooter;
@property (strong, nonatomic) UIView *paginationFooter;

@property (nonatomic, assign) BOOL showPullToRefresh;
@property (nonatomic, strong, readonly) RPPullToRefreshView *pullToRefreshView;

- (void)setDefaultFooter;
- (void)setPaginationFooter;

- (void)addPullToRefreshActionHandler:(RefreshHandler)handler;
- (void)addPullToRefreshActionHandlerForStore:(RefreshHandler)handler;

- (void)triggerPullToRefresh;
- (void)stopRefreshAnimation;

@end