//
//  ORVCRefreshHeaderViewController.m
//  Spinner
//
//  Created by Emil on 1/13/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPReloadControl.h"
#import "RPSpinner.h"

#define MAX_SCROLL_GAP 70

typedef enum  {
    RefreshStateNormal,
    RefreshStatePulling,
    RefreshStateLoading
} PullState;


static const CGFloat kDistanFromTop = 65;

@interface RPReloadControl ()

@property (strong, nonatomic) RPSpinner *spinner;
@property (assign, nonatomic) PullState state;
@property (weak,   nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL fixForStoreController;


@end

@implementation RPReloadControl


#pragma mark - Init

- (instancetype)initWithTableView:(UITableView*)tableView andImagedNamed:(NSString*)imageName isStore:(BOOL)isStore
{

    if (isStore) {
        self.fixForStoreController = YES;
    }

    self = [super init];

    self.tableView = tableView;
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    tableView.backgroundView = self;

    self.backgroundColor = [UIColor clearColor];

    self.frame = tableView.frame;
    self.spinner = [[RPSpinner alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];

    [self.spinner setImageNamed:imageName];
    self.spinner.hideWhenFinish = YES;

    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;


    [self addSubview:self.spinner];

    NSDictionary *views = @{@"spinner": self.spinner};

    CGFloat dis = self.fixForStoreController ? 20 : kDistanFromTop;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[spinner(34)]",  dis]
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];

    [self addConstraint: [NSLayoutConstraint
                          constraintWithItem:self.spinner
                          attribute:NSLayoutAttributeCenterX
                          relatedBy:0
                          toItem:self
                          attribute:NSLayoutAttributeCenterX
                          multiplier:1
                          constant:0]];
    
    return self;
}


- (instancetype)initWithTableView:(UITableView*)tableView andImagedNamed:(NSString*)imageName;
{
    return [self initWithTableView:tableView andImagedNamed:imageName isStore:NO];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
        self.tableView = nil;
    }
}

- (void)awakeFromNib
{
    [self setState:RefreshStateNormal];
    self.spinner.alpha = 0;
}


#pragma mark - State

- (void)setState:(PullState)state
{

    if (state != _state) {

        _state = state;
        switch (state) {
            case RefreshStateNormal:
                [self endControllerAnimation];
                break;

            case RefreshStatePulling:
                self.spinner.fillingPercent = 100;
                break;

            case RefreshStateLoading:
                [self startControllerAnimation];
                break;
        }
    }
}

- (void)setPullingAnimationWithCurrentGap:(CGFloat)topGap
{

    if (topGap >= 5 && self.state == RefreshStateNormal) {
        CGFloat completedAngle =  (topGap -15) / ( MAX_SCROLL_GAP -15) * 100;

        if (completedAngle <= 100 && completedAngle >= 0) {
            self.spinner.fillingPercent = completedAngle;
        }
    }

    BOOL tableHasCells = [self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > 0;

    if (self.state != RefreshStateLoading || tableHasCells) {
        self.spinner.alpha = (topGap  < 1) ? 0 : 1;

    }

}

- (BOOL)isRefreshing
{
    return [self state] == RefreshStateLoading;
}


#pragma mark - Public

- (void)beginRefreshing
{
    [self setState:RefreshStateLoading];
}

- (void)endRefreshing
{
    [self setState:RefreshStateNormal];
}


#pragma mark - Table View Value observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"contentOffset"] ) {
        CGFloat dis = self.fixForStoreController ? 0 : kDistanFromTop;

        CGFloat y = ([change[@"new"] CGPointValue].y + dis) * -1;

        static BOOL isFirstTime = YES;
        if (isFirstTime) {

            isFirstTime = NO;
        }

        [self setPullingAnimationWithCurrentGap:y];

        if (self.tableView.isDragging) {
            if (self.state == RefreshStatePulling && y < MAX_SCROLL_GAP && y > 0.0f) {
                [self setState:RefreshStateNormal];
            }
            else if (self.state == RefreshStateNormal && y >= MAX_SCROLL_GAP) {
                [self setState:RefreshStatePulling];
            }
        }
        else if (y >= MAX_SCROLL_GAP) {
            [self setState: RefreshStateLoading];
        }
    }
}


#pragma mark - TableView Animations

- (void)startControllerAnimation
{
    CGFloat dis = self.fixForStoreController ? 0 : kDistanFromTop;
    [UIView animateWithDuration:0.3 delay:0.4 options: 0 animations:^{
        self.spinner.alpha = 1;
        self.tableView.contentInset = UIEdgeInsetsMake(self.spinner.bounds.size.height * 1.2 + dis, 0.0f, 0.0f, 0.0f);
        [self.spinner startAnimating];

    } completion:^(BOOL finished) {

        if (self.handler) {
            self.handler();
        }
    }];
}

- (void)endControllerAnimation
{
    CGFloat dis = self.fixForStoreController ? 0 : kDistanFromTop;

    [UIView animateWithDuration:0.3 animations:^{
        [self setPullingAnimationWithCurrentGap:-1];
        [self.tableView setContentInset:UIEdgeInsetsMake(dis, 0.0f, 0.0f, 0.0f)];

    } completion:^(BOOL finished) {
        [self.spinner stopAnimating];
        
    }];
}

@end
