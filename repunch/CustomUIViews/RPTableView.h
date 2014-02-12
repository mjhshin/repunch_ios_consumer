//
//  RPTableView.h
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPTableView : UITableView

- (void)setDefaultFooter;
- (void)setPaginationFooter;

@property (strong, nonatomic) UIView *defaultFooter;
@property (strong, nonatomic) UIView *paginationFooter;

@end
