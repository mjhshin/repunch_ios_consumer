//
//  RPTableView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPTableView.h"
#import <objc/runtime.h>
static char UIScrollViewPullToRefreshView;

@implementation RPTableView
@dynamic pullToRefreshView, showPullToRefresh;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder]) {
		[self initFooters];
		[self setDefaultFooter];
	}
	
	return self;
}

- (void)initFooters
{
	// default footer
	self.defaultFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
	self.defaultFooter.backgroundColor = [UIColor whiteColor];
	
	// pagination footer
	self.paginationFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
	self.paginationFooter.backgroundColor = [UIColor whiteColor];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.frame = self.paginationFooter.bounds;
	[spinner startAnimating];
	
	[self.paginationFooter addSubview:spinner];
}

- (void)setDefaultFooter
{
	self.tableFooterView = self.defaultFooter;
}

- (void)setPaginationFooter
{
	self.tableFooterView = self.paginationFooter;
}


- (void)addPullToRefreshActionHandler:(actionHandler)handler
{
    if(self.pullToRefreshView == nil)
    {
        RPActivityIndicatorView *view = [[RPActivityIndicatorView alloc] init];
        view.pullToRefreshHandler = handler;
        view.scrollView = self;
        view.frame = CGRectMake((self.bounds.size.width - view.bounds.size.width)/2,
                                -view.bounds.size.height, view.bounds.size.width, view.bounds.size.height);
        view.originalTopInset = 64.0f;//self.contentInset.top;
        [self addSubview:view];
        [self sendSubviewToBack:view];
        self.pullToRefreshView = view;
        self.showPullToRefresh = YES;
    }
}

- (void)triggerPullToRefresh
{
    [self.pullToRefreshView manuallyTriggered];
}

- (void)stopRefreshAnimation
{
    [self.pullToRefreshView stopIndicatorAnimation];
}

#pragma mark - property

- (void)setPullToRefreshView:(RPActivityIndicatorView *)pullToRefreshView
{
    [self willChangeValueForKey:@"UzysRadialProgressActivityIndicator"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView, pullToRefreshView, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UzysRadialProgressActivityIndicator"];
}

- (RPActivityIndicatorView *)pullToRefreshView
{
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowPullToRefresh:(BOOL)showPullToRefresh
{
    self.pullToRefreshView.hidden = !showPullToRefresh;
    
    if(showPullToRefresh)
    {
        if(!self.pullToRefreshView.isObserving)
        {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
        }
    }
    else
    {
        if(self.pullToRefreshView.isObserving)
        {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentSize"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            self.pullToRefreshView.isObserving = NO;
        }
    }
}

- (BOOL)showPullToRefresh
{
    return !self.pullToRefreshView.hidden;
}

@end
