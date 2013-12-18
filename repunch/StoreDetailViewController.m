//
//  StoreDetailViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 12/18/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "StoreLocationViewController.h"
#import "StoreDetailTableViewCell.h"
#import "RPStoreLocation.h"

@interface StoreDetailViewController()

@end

@implementation StoreDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.store.store_locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[StoreDetailTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [StoreDetailTableViewCell cell];
    }
	
	RPStoreLocation *storeLocation = self.store.store_locations[indexPath.row];
    
	cell.locationTitle.text = storeLocation.street;
	cell.locationSubtitle.text = storeLocation.city;
	//cell.locationDistance;
	//cell.locationHours;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreLocationViewController *storeLocationVC = [[StoreLocationViewController alloc] init];
    
    // Push the view controller.
    [self.navigationController pushViewController:storeLocationVC animated:YES];
}

@end
