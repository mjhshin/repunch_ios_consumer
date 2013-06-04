//
//  SettingsSortViewController.m
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "SettingsSortViewController.h"

@interface SettingsSortViewController ()

@end

@implementation SettingsSortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Sort Retailers";
    
    UITableView *sortTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [sortTableView setDataSource:self];
    [sortTableView setDelegate:self];
    
    [self.view addSubview:sortTableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Alphabetical Order";
            break;
        case 1:
            cell.textLabel.text = @"Number of Punches";
            break;
        case 2:
            cell.textLabel.text = @"Number of Rewards";
            break;
    }
    
    if ([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"sort"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] != UITableViewCellAccessoryCheckmark) {
        // set it and unset the others
        for (int i = 0; i < 3; i++) {
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] forKey:@"sort"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
