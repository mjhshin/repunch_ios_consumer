//
//  SettingsViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "GradientBackground.h"
#import "DataManager.h"

@implementation SettingsViewController
{
	DataManager *sharedData;
	UIActivityIndicatorView *activityIndicator;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Settings";
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"nav_exit.png"]
								   style:UIBarButtonItemStylePlain
								   target:self
								   action:@selector(closeView:)];
	self.navigationItem.leftBarButtonItem = exitButton;
	
	sharedData = [DataManager getSharedInstance];
    
	/*
	 PFObject* patron = [sharedData patron];
	 NSString* str1 = @"Logged in as ";
	 NSString* firstName = [patron objectForKey:@"first_name"];
	 NSString* str2 = @" ";
	 NSString* lastName = [patron objectForKey:@"last_name"];
	 
	 //self.currentLogin.text = [NSString stringWithFormat:@"%@%@%@%@", str1, firstName, str2, lastName];
	 */
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGFloat screenWidth = screenRect.size.width;
	CGFloat screenHeight = screenRect.size.height;
	CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
	
	UITableView *settingsTableView = [[UITableView alloc]
									  initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - navBarHeight)
									  style:UITableViewStyleGrouped];
	settingsTableView.delegate = self;
	settingsTableView.dataSource = self;
	[self.view addSubview:settingsTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0) {
		return 2;
	} else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.section == 1) ? 60 : 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor darkTextColor];
    label.font = [UIFont fontWithName:@"Avenir" size:18];
    label.backgroundColor = [UIColor clearColor];
	
	if(section == 0) {
		label.text = @"Legal";
	}
	else {
		label.text = @"Information";
	}

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	CGRect frame = view.bounds;
	frame.origin.x += 15;
	label.frame = frame;
    [view addSubview:label];
	
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	if(indexPath.section == 0)
	{
		static NSString *Style1CellIdentifier = @"Style1Cell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:Style1CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Style1CellIdentifier];
		}
		
		if(indexPath.row == 0) {
			cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
			cell.textLabel.text = @"Terms and Conditions";
		}
		else {
			cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
			cell.textLabel.text = @"Privacy Policy";
		}
	}
	else
	{
		static NSString *Style2CellIdentifier = @"Style1Cell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:Style2CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Style2CellIdentifier];
		}
		cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
		cell.textLabel.text = @"Log Out";
		
		PFObject* patron = [sharedData patron];
		NSString* str1 = @"Logged in as ";
		NSString* firstName = [patron objectForKey:@"first_name"];
		NSString* str2 = @" ";
		NSString* lastName = [patron objectForKey:@"last_name"];
		
		cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir" size:14];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", str1, firstName, str2, lastName];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(indexPath.section == 0)
	{
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator.hidesWhenStopped = YES;
		
		if(indexPath.row == 0) {
			UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.repunch.com/terms-mobile"]]];
			webView.delegate = self;
			
			UIViewController *termsVC = [[UIViewController alloc] init];
			[termsVC.view addSubview:webView];
			[termsVC.view addSubview:activityIndicator];
			activityIndicator.center = webView.center;
			
			termsVC.navigationItem.title = @"Terms and Conditions";
			[self.navigationController pushViewController:termsVC animated:YES];
		}
		else
		{
			UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.repunch.com/privacy-mobile"]]];
			webView.delegate = self;
			
			UIViewController *privacyVC = [[UIViewController alloc] init];
			[privacyVC.view addSubview:webView];
			[privacyVC.view addSubview:activityIndicator];
			activityIndicator.center = webView.center;
			
			privacyVC.navigationItem.title = @"Privacy Policy";
			[self.navigationController pushViewController:privacyVC animated:YES];
		}
	}
	else
	{
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.hidesWhenStopped = YES;
		spinner.frame = CGRectMake(0, 0, 24, 24);
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryView = spinner;
		[spinner startAnimating];
		tableView.userInteractionEnabled = NO;
		
		//set blank "patron_id" and "punch_code" in installation so push notifications not received when logged out.
		[[PFInstallation currentInstallation] setObject:@"" forKey:@"punch_code"];
		[[PFInstallation currentInstallation] setObject:@"" forKey:@"patron_id"];
		[[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		 {
			 [spinner stopAnimating];
			 tableView.userInteractionEnabled = YES;
			 
			 if(!error)
			 {
				 [self dismissViewControllerAnimated:YES completion:nil];
				 [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
				 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				 [appDelegate logout];
			 }
			 else
			 {
				 SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Failed to Log Out"
															  andMessage:@"Sorry, something went wrong"];
				 [alert addButtonWithTitle:@"OK"
									  type:SIAlertViewButtonTypeDefault
								   handler:nil];
				 [alert show];
			 }
		 }];

	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
}

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDialog:(NSString*)resultTitle withResultMessage:(NSString*)resultMessage
{
	[[[UIAlertView alloc] initWithTitle:resultTitle
								message:resultMessage
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles: nil] show];
}

@end
