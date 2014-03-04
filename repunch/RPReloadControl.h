//
//  ORVCRefreshHeaderViewController.h
//  Spinner
//
//  Created by Emil on 1/13/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReloadHandler)();

@interface RPReloadControl : UIView

@property (copy) ReloadHandler handler;
@property (atomic, readonly) BOOL isRefreshing;

- (instancetype)initWithTableView:(UITableView*)tableView
				   andImageNamed:(NSString*)imageName;

- (instancetype)initWithTableView:(UITableView*)tableView
				   andImageNamed:(NSString*)imageName
						  isStore:(BOOL)isStore;

- (void)beginRefreshing;
- (void)endRefreshing;

@end
