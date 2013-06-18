//
//  PlacesViewController.m
//  Repunch
//
//  Created by Gwendolyn Weston on 6/17/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlacesSearchViewController.h"
#import "GlobalToolbar.h"

//JUST FOR MY OWN SANITY, what's goingon:
//on viewdidload: set up UI, meaning global toolbar, tableview
//on viewwillappear: set up model+data sources, meaning all saved_stores

//settings button goes to settings page
//search button goes to search page
//clicking on table cell goes to place detail view

//TODO ON THIS PAGE:

@implementation PlacesViewController{
    GlobalToolbar *globalToolbar;
}

- (void)setup {
    // Non-UI initialization goes here. It will only ever be called once.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    globalToolbar = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
    [(GlobalToolbar *)globalToolbar setToolbarDelegate:self];
    [self.view addSubview:globalToolbar];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Most data loading should go here to make sure the view matches the model
    // every time it's put on the screen. This is also a good place to observe
    // notifications and KVO, and to setup timers.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Unregister from notifications and KVO here (balancing viewWillAppear:).
    // Stop timers.
    // This is a good place to tidy things up, free memory, save things to
    // the model, etc.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Global Toolbar Delegate

- (void) openSettings
{
}


- (void) openSearch
{
    PlacesSearchViewController *placesSearchVC = [[PlacesSearchViewController alloc]init];
    placesSearchVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    placesSearchVC.modalDelegate = self;
    [placesSearchVC setup];
    [self presentViewController:placesSearchVC animated:YES completion:NULL];
}

- (void)didDismissPresentedViewController{
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
