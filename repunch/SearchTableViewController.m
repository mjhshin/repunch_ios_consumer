//
//  SearchTableViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SearchTableViewController.h"
#import "StoreViewController.h"
#import "RPPullToRefreshView.h"

@implementation SearchTableViewController {
	NSMutableDictionary *imageDownloadsInProgress;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	__weak typeof(self) weakSelf = self;
	[self.tableView addPullToRefreshActionHandler:^{
		[weakSelf.delegate refreshData:weakSelf forPaginate:NO];
	}];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	// terminate all pending image downloads
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelImageDownload)];
    [imageDownloadsInProgress removeAllObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.storeLocationIdArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchTableViewCell reuseIdentifier]];
	
	if (cell == nil) {
        cell = [SearchTableViewCell cell];
    }
	
	NSString *storeLocationId = self.storeLocationIdArray[indexPath.row];
	RPStoreLocation *storeLocation = [[DataManager getSharedInstance] getStoreLocation:storeLocationId];
	RPStore *store = [[DataManager getSharedInstance] getStore:storeLocation.Store.objectId];
	
	// Set distance to store
	double distanceToStore = [self.userLocation distanceInMilesTo:storeLocation.coordinates];
	cell.distance.text = [RepunchUtils formattedDistance:distanceToStore];
	
	// Set address
	NSString *street = storeLocation.street;
	
	if ( !IS_NIL(storeLocation.neighborhood) ) {
		street = [street stringByAppendingFormat:@", %@", storeLocation.neighborhood];
	}
	else {
		street = [street stringByAppendingFormat:@", %@", storeLocation.city];
	}
	
	// Set Categories
	NSString *formattedCategories = @"";
	
	for (int i = 0; i < store.categories.count; i++)
	{
		formattedCategories = [formattedCategories stringByAppendingString:store.categories[i][@"name"]];
		
		if (i != [store.categories count] - 1) {
			formattedCategories = [formattedCategories stringByAppendingFormat:@", "];
		}
	}
	
	// Set punches and reward info
	RPPatronStore *patronStore = [[DataManager getSharedInstance] getPatronStore:store.objectId];
	
	if(patronStore == nil) {
		[cell.punchIcon setHidden:YES];
		[cell.numPunches setHidden:YES];
	}
	else {
		NSInteger punchCount = patronStore.punch_count;
		[cell.punchIcon setHidden:NO];
		[cell.numPunches setHidden:NO];
		[cell.numPunches setText:[NSString stringWithFormat:@"%d %@", punchCount, (punchCount == 1) ? @"Punch" : @"Punches"]];
	}
	
	cell.storeAddress.text = street;
	cell.storeCategories.text = formattedCategories;
	cell.storeName.text = store.store_name;
	
	// Only load cached images; defer new downloads until scrolling ends
    //if (cell.storeImage == nil)
    //{
	//if (self.myPlacesTableView.dragging == NO && self.myPlacesTableView.decelerating == NO)
	//{
	if( !IS_NIL(store.thumbnail_image) )
	{
		cell.storeImage.image = [UIImage imageNamed:@"PlaceholderThumbnail"];
		UIImage *storeImage = [[DataManager getSharedInstance] getThumbnailImage:store.objectId];
		if(storeImage == nil)
		{
			cell.storeImage.image = [UIImage imageNamed:@"PlaceholderThumbnail"];
			[self downloadImage:store.thumbnail_image forIndexPath:indexPath withStoreId:store.objectId];
		} else {
			cell.storeImage.image = storeImage;
		}
	} else {
		// if a download is deferred or in progress, return a placeholder image
		cell.storeImage.image = [UIImage imageNamed:@"PlaceholderThumbnail"];
	}
	//}
    //}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *storeLocationId = self.storeLocationIdArray[indexPath.row];
	RPStoreLocation *storeLocation = [[DataManager getSharedInstance] getStoreLocation:storeLocationId];
	
	StoreViewController *storeVC = [[StoreViewController alloc] init];
	storeVC.storeId = storeLocation.Store.objectId;
	storeVC.storeLocationId = storeLocationId;
	[self.navigationController pushViewController:storeVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat adjustments = MIN(scrollView.contentSize.height, scrollView.bounds.size.height) - scrollView.contentInset.bottom;
	CGFloat scrollLocation = scrollView.contentOffset.y + adjustments;
	CGFloat overScrollPoint = MAX(scrollView.contentSize.height, scrollView.bounds.size.height) - 20.0;
	
    if(scrollLocation >= overScrollPoint && !self.loadInProgress && !self.paginateReachEnd) {
		[self.delegate refreshData:self forPaginate:YES];
    }
}

- (void)downloadImage:(PFFile *)imageFile forIndexPath:(NSIndexPath *)indexPath withStoreId:(NSString *)storeId
{
	if( ![RepunchUtils isConnectionAvailable] ) {
		return;
	}
	
    PFFile *existingImageFile = imageDownloadsInProgress[indexPath];
    if (existingImageFile == nil)
    {
        [imageDownloadsInProgress setObject:imageFile forKey:indexPath];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			
			if (!error) {
				SearchTableViewCell *cell = (SearchTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
				UIImage *storeImage = [UIImage imageWithData:data];
				//cell.storeImage.image = storeImage;
				[cell.storeImage setImageWithAnimation:storeImage];
				[imageDownloadsInProgress removeObjectForKey:indexPath]; // Remove the PFFile from the in-progress list
				[[DataManager getSharedInstance] addThumbnailImage:storeImage forKey:storeId];
			}
			else {
				NSLog(@"image download failed");
			}
		}];
    }
}

- (void)cancelImageDownload
{
    for(PFFile *imageFile in imageDownloadsInProgress) {
        [imageFile cancel];
    }
}

- (void)showRefreshViews:(BOOL)paginate
{
	if(paginate) {
		[self.tableView setPaginationFooter];
	}
	else if(self.storeLocationIdArray.count == 0) {
		self.activityIndicatorView.hidden = NO;
		[self.activityIndicator startAnimating];
	}
}

- (void)hideRefreshViews:(BOOL)paginate
{
	if(paginate) {
		[self.tableView setDefaultFooter];
	}
	else {
		[self.tableView stopRefreshAnimation];
		[self.activityIndicator stopAnimating];
		self.activityIndicatorView.hidden = YES;
	}
}

- (void)refreshTableView
{
	if(self.storeLocationIdArray.count > 0) {
		self.emptyResultsLabel.hidden = YES;
	}
	else {
		self.emptyResultsLabel.hidden = NO;
	}
	
	[self.tableView reloadData];
}


@end
