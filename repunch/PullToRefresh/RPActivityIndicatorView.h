//
//  RPActivityIndicator.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^actionHandler)(void);

typedef NS_ENUM (NSUInteger, RPPullToRefreshState) {
    RPPullToRefreshStateNone = 0,
    RPPullToRefreshStateStopped,
    RPPullToRefreshStateTriggering,
    RPPullToRefreshStateTriggered,
    RPPullToRefreshStateLoading,
};

@interface RPActivityIndicatorView : UIView

@property (nonatomic,assign) BOOL isObserving;
@property (nonatomic,assign) CGFloat originalTopInset;
@property (nonatomic,assign) RPPullToRefreshState state;
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,copy) actionHandler pullToRefreshHandler;

@property (nonatomic,strong) UIImage *imageIcon;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;

- (void)stopIndicatorAnimation;
- (void)manuallyTriggered;

- (void)setSize:(CGSize)size;

@end
