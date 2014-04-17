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

#define kAnimateDelay 0.5f
#define kAnimateDuration 0.5f
#define kCountDuration 0.8f

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
	_punchCountLabel.method = UILabelCountingMethodLinear;
	_punchCountLabel.text = [NSString stringWithFormat:@"%i", 6];
	
	[self showPunchesReceivedLabel];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PunchComplete" object:self userInfo:nil];
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

- (void)showPunchesReceivedLabel
{
	[UIView animateWithDuration:kAnimateDuration
						  delay:kAnimateDelay
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _punchReceivedLabel.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [self showPunchCountView];
					 }];
}

- (void)showPunchCountView
{
	[UIView animateWithDuration:kAnimateDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _punchCountView.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [_punchCountLabel countFrom:6
												  to:12
										withDuration:kCountDuration];
						 
						 [self showUnlockedRewardsLabel];
						 //[self checkUnlockedRewards];
					 }];
}

- (void)showUnlockedRewardsLabel
{
	[UIView animateWithDuration:kAnimateDuration
						  delay:kCountDuration
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _unlockedRewardLabel.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [UIView animateWithDuration:kAnimateDuration
											   delay:0.0f
											 options:UIViewAnimationOptionCurveEaseIn
										  animations:^{
											  _rewardTitleLabel.alpha = 1.0f;
											  _moreRewardsLabel.alpha = 1.0f;
										  }
										  completion:nil];
					 }];
}

- (void)checkUnlockedRewards
{
	RPStore *store = [[DataManager getSharedInstance] getStore:_storeId]; //TODO: when store is not in cache
	RPPatronStore *patronStore = [[DataManager getSharedInstance] getPatronStore:_storeId];
	
	BOOL didUnlockReward = NO;
	NSUInteger firstUnlockedIndex = 0;
	NSUInteger unlockedRewards = 0;
	
	for (int i = 0; i < store.rewards.count; i++) {
		if(patronStore.punch_count < [store.rewards[i][@"punches"] intValue]
		   && patronStore.punch_count + _punchesReceived >= [store.rewards[i][@"punches"] intValue]) {
			didUnlockReward = YES;
			unlockedRewards++;
			
			if(firstUnlockedIndex == 0)
				firstUnlockedIndex = i;
		}
		else if(patronStore.punch_count + _punchesReceived < [store.rewards[i][@"punches"] intValue]) {
			break;
		}
	}
	
	if(didUnlockReward) {
		_rewardTitleLabel.text = store.rewards[firstUnlockedIndex][@"reward_name"];
		
		if(unlockedRewards > 1) {
			_moreRewardsLabel.text = [NSString stringWithFormat:@"+%i other rewards", unlockedRewards - 1];
		}
		
		[UIView animateWithDuration:kAnimateDuration
							  delay:kCountDuration
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 _unlockedRewardLabel.alpha = 1.0f;
						 }
						 completion:^(BOOL completed) {
							 [UIView animateWithDuration:kAnimateDuration
												   delay:0.0f
												 options:UIViewAnimationOptionCurveEaseIn
											  animations:^{
												  _rewardTitleLabel.alpha = 1.0f;
												  if(unlockedRewards > 1) {
													  _moreRewardsLabel.alpha = 1.0f;
												  }
											  }
											  completion:nil];
						 }];
	}
}

@end
