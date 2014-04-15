//
//  PunchResultViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 4/14/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "PunchResultViewController.h"
#import "DataManager.h"
#import "RPStore.h"

@interface PunchResultViewController ()

@end

@implementation PunchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_punchReceivedLabel.alpha = 0.0f;
	_punchCountView.alpha = 0.0f;
	_unlockedRewardLabel.alpha = 0.0f;
	_rewardTitleLabel.alpha = 0.0f;
	_moreRewardsLabel.alpha = 0.0f;
	
	_punchReceivedLabel.text = (_punchesReceived == 1) ? @"You received 1 punch!" :
		[NSString stringWithFormat:@"You received %i punches!", _punchesReceived];
	_punchCountLabel.format = @"%d";
	_punchCountLabel.text = [NSString stringWithFormat:@"%i", 6];
	_punchCountLabel.method = UILabelCountingMethodLinear;
	
	[UIView animateWithDuration:0.5
						  delay:0.5
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _punchReceivedLabel.alpha = 1.0f;
						 _punchCountView.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [_punchCountLabel countFrom:6
												  to:12
										withDuration:0.8f];
					 }];
	
	_punchReceivedLabel.text = (_punchesReceived == 1) ? @"You received 1 punch!" :
								[NSString stringWithFormat:@"You received %i punches!", _punchesReceived];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"PunchComplete" object:self userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animatePunchCount
{
	
}


- (void)checkUnlockedRewards
{
	/*
	RPStore *store = [[DataManager getSharedInstance] getStore:_storeId]; //TODO: when store is not in cache
	RPPatronStore *patronStore = [[DataManager getSharedInstance] getPatronStore:_storeId];
	
	BOOL didUnlockReward = NO;
	NSInteger startIndex = 0;
	
	for (int i=0; i<store.rewards.count; i++) {
		if(patronStore.punch_count <
	}
	 */
}

@end
