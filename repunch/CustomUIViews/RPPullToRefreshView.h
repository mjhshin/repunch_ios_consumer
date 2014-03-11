//
//  RPPullToRefreshView.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RefreshHandler)(void);

typedef NS_ENUM (NSUInteger, RPPullToRefreshState) {
    RPPullToRefreshStateNone = 0,
    RPPullToRefreshStateStopped,
    RPPullToRefreshStateTriggering,
    RPPullToRefreshStateTriggered,
    RPPullToRefreshStateLoading
};

@class RPTableView;

@interface RPPullToRefreshView : UIView

@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, assign) CGFloat originalTopInset;
@property (nonatomic, assign) RPPullToRefreshState state;
@property (nonatomic, weak) RPTableView *tableView;
@property (nonatomic, copy) RefreshHandler pullToRefreshHandler;

@property (nonatomic, strong) UIImage *imageIcon;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

- (void)stopIndicatorAnimation;
- (void)manuallyTriggered;

- (void)setSize:(CGSize)size;
- (void)setContentInsetTop:(CGFloat)topInset;

- (void)styleForStore;

@end
