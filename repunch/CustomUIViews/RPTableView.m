//
//  RPTableView.m
//  RepunchConsumer
//
//  Created by Michael Shin on 2/11/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RPTableView.h"

@implementation RPTableView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self initFooters];
	[self setDefaultFooter];
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

@end
