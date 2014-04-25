//
//  PunchViewController.m
//  BLE Central
//
//  Created by Michael Shin on 4/8/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import "PunchViewController.h"
#import "BluetoothManager.h"
#import "RepunchUtils.h"
#import "RPConstants.h"
#import "DataManager.h"

#define kAnimateDelay 0.5f
#define kAnimateFadeDuration 0.3f
#define kAnimateSlideDuration 0.3f
#define kCountDuration 0.8f
#define kStoreNameLabelTopConstraintAfterPunch 60.0f

@interface PunchViewController ()

@property (strong, nonatomic) BluetoothManager *bluetoothManager;
@property (assign, nonatomic) BOOL punchRequested;

@property (strong, nonatomic) NSString *storeName;
@property (strong, nonatomic) NSString *storeId;
@property (assign, nonatomic) NSUInteger punchesReceived;
@property (assign, nonatomic) NSUInteger oldPunchCount;

@property (strong, nonatomic) RPPatronStore *patronStore;

@end

@implementation PunchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_bluetoothManager = [BluetoothManager getSharedInstance];
	_punchRequested = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkBluetoothManagerState)
												 name:kNotificationBluetoothStateChange
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(discoveredStore:)
												 name:kNotificationBluetoothStoreDiscovered
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receivedPunch:)
												 name:kNotificationBluetoothReceivedPunch
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeConnected:)
												 name:kNotificationBluetoothStoreConnected
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeDisconnected)
												 name:kNotificationBluetoothStoreDisconnected
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeNotFound)
												 name:kNotificationBluetoothScanTimeout
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(bluetoothError)
												 name:kNotificationBluetoothError
											   object:nil];
	[self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self requestPunch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initViews
{
	[self.view addSubview:_backgroundImageView];
	_backgroundImageView.layer.zPosition = -1;
	
	_radarView.hidden = YES;
	_statusImageView.hidden = YES;
	_statusLabel.hidden = YES;
	_storeNameLabel.hidden = YES;
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	_resultView.hidden = YES;
	
	_storeNameLabel.textColor = [RepunchUtils repunchOrangeColor];
	_punchCountLabel.textColor = [RepunchUtils repunchOrangeColor];
	_rewardTitleLabel.textColor = [RepunchUtils repunchOrangeColor];
	_moreRewardsLabel.textColor = [RepunchUtils repunchOrangeColor];
}

- (void)setViewsForScanning
{
	_radarView.hidden = NO;
	_statusLabel.text = @"Searching...";
	_statusLabel.hidden = NO;
	_statusImageView.hidden = YES;
	_storeNameLabel.hidden = YES;
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	
	[_radarView startAnimation];
}

- (void)setViewsForPunch
{
	_radarView.hidden = YES;
	_statusLabel.hidden = YES;
	_statusImageView.hidden = YES;
	_storeNameLabel.hidden = NO;
	_explanationLabel.hidden = NO;
	_wrongStoreButton.hidden = NO;
	
	[_radarView stopAnimation];
}

- (void)checkBluetoothManagerState
{
	if(_bluetoothManager.state == CBCentralManagerStatePoweredOn && _punchRequested) {
		[_bluetoothManager requestPunchesFromNearestStore];
	}
	else if(_bluetoothManager.state == CBCentralManagerStatePoweredOff) {
		//prompt to turn on
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnauthorized) {
		//prompt to authorize
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnsupported) {
		//error
	}
}

- (void)requestPunch
{
	_punchRequested = YES;
	[self setViewsForScanning];
	[self checkBluetoothManagerState];
}

- (void)cancelPunchRequest
{
	_punchRequested = NO;
	[_bluetoothManager cancelRequest];
}

- (void)discoveredStore:(NSNotification *)notification
{
	// is this needed?
}

- (void)receivedPunch:(NSNotification *)notification
{
	_punchesReceived = [notification.userInfo[kNotificationBluetoothPunches] integerValue];
	
	[self getPatronStore];
}

- (void)storeConnected:(NSNotification *)notification
{
	_storeId = notification.userInfo[kNotificationBluetoothStoreId];
	_storeName = notification.userInfo[kNotificationBluetoothStoreName];
	_storeNameLabel.text = _storeName;
	
	[self setViewsForPunch];
	
	_storeNameLabel.alpha = 0.0f;
	_explanationLabel.alpha = 0.0f;
	_wrongStoreButton.alpha = 0.0f;
	
	[UIView animateWithDuration:kAnimateFadeDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _storeNameLabel.alpha = 1.0f;
						 _explanationLabel.alpha = 1.0f;
						 _wrongStoreButton.alpha = 1.0f;
					 }
					 completion:nil];
}

- (void)storeDisconnected
{
	NSLog(@"Store disconnected");
	_punchRequested = NO;
	//disconnects on punch complete. Is this needed?
	//[self bluetoothError];
}

- (void)storeNotFound
{
	NSLog(@"Store not found");
	_statusLabel.text = @"Sorry, we couldn't find \n any stores nearby.";
	_statusImageView.image = [UIImage imageNamed:@"bluetooth_not_found"];
	
	_radarView.hidden = YES;
	_statusLabel.hidden = NO;
	_statusImageView.hidden = NO;
	_storeNameLabel.hidden = YES;
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	
	[_radarView stopAnimation];
}

- (void)bluetoothError
{
	_statusLabel.text = @"Sorry, something went wrong.";
	_statusImageView.image = [UIImage imageNamed:@"bluetooth_error"];
	
	_radarView.hidden = YES;
	_statusLabel.hidden = NO;
	_statusImageView.hidden = NO;
	_storeNameLabel.hidden = YES;
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	
	[_radarView stopAnimation];
}


- (void)getPatronStore
{
	DataManager *dataManager = [DataManager getSharedInstance];
	_patronStore = [dataManager getPatronStore:_storeId];
	//RPStore *store = [dataManager getStore:_storeId];
	
	if(_patronStore) {
		_oldPunchCount = _patronStore.punch_count;
		
		_patronStore.punch_count += _punchesReceived;
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPunch object:self];
		
		[self showPunchesReceived];
	}
	else {
		RPPatron *patron = [dataManager patron];
		PFRelation *patronStoreRelation = [patron relationforKey:@"PatronStores"];
		
		PFQuery *storeQuery = [RPStore query];
		[storeQuery whereKey:@"objectId" equalTo:_storeId];
		
		PFQuery *patronStoreQuery = [patronStoreRelation query];
		[patronStoreQuery includeKey:@"Store.store_locations"];
		[patronStoreQuery includeKey:@"FacebookPost"];
		[patronStoreQuery whereKey:@"Store" matchesQuery:storeQuery];
		
		__weak typeof(self) weakSelf = self;
		[patronStoreQuery getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
			
			if (!error) {
				RPPatronStore *newPatronStore = (RPPatronStore *)result;
				
				[dataManager addPatronStore:newPatronStore forKey:weakSelf.storeId];
				[dataManager addStore:newPatronStore.Store];
				
				weakSelf.patronStore = newPatronStore;
				weakSelf.oldPunchCount = newPatronStore.punch_count -  weakSelf.punchesReceived; //TODO: lets make this cleaner
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPunch object:self];
				
				[self showPunchesReceived];
			}
			else {
				NSLog(@"PatronStore query error: %@", error);
				//TODO: Error!
			}
		}];
	}
}

- (void)showPunchesReceived
{
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	_resultView.hidden = NO;
	
	_punchReceivedLabel.alpha = 0.0f;
	_punchCountView.alpha = 0.0f;
	_unlockedRewardLabel.alpha = 0.0f;
	_rewardTitleLabel.alpha = 0.0f;
	_moreRewardsLabel.alpha = 0.0f;
	
	_punchReceivedLabel.text = (_punchesReceived == 1) ? @"You received 1 punch!" :
									[NSString stringWithFormat:@"You received %i punches!", _punchesReceived];
	_punchCountLabel.format = @"%d";
	_punchCountLabel.method = UILabelCountingMethodLinear;
	_punchCountLabel.text = [NSString stringWithFormat:@"%i", _oldPunchCount];
	
	[UIView animateWithDuration:kAnimateSlideDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _storeNameLabelTopConstraint.constant = kStoreNameLabelTopConstraintAfterPunch;
						 [self.view layoutIfNeeded];
					 }
					 completion:^(BOOL completed) {
						 [self showPunchesReceivedLabel];
					 }];
}

- (void)showPunchesReceivedLabel
{
	[UIView animateWithDuration:kAnimateFadeDuration
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
	[UIView animateWithDuration:kAnimateFadeDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _punchCountView.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [_punchCountLabel countFrom:_oldPunchCount
												  to:_oldPunchCount + _punchesReceived
										withDuration:kCountDuration];
						 
						 [self checkUnlockedRewards];
					 }];
}

- (void)checkUnlockedRewards
{
	DataManager *dataManager = [DataManager getSharedInstance];
	RPStore *store = [dataManager getStore:_storeId];
	
	NSUInteger unlockedRewards = 0;
	
	for(int i = 0; i < store.rewards.count; i++) {
		NSUInteger rewardPunches = [store.rewards[i][@"punches"] intValue];
		if(_oldPunchCount < rewardPunches && _oldPunchCount + _punchesReceived >= rewardPunches) {
			if(unlockedRewards == 0) {
				_rewardTitleLabel.text = store.rewards[i][@"reward_name"];
			}
			++unlockedRewards;
		}
		else if(rewardPunches > _oldPunchCount + _punchesReceived) {
			break;
		}
	}
	
	if(unlockedRewards > 0) {
		if(unlockedRewards > 1) {
			_moreRewardsLabel.text = [NSString stringWithFormat:@"+%i other rewards", unlockedRewards - 1];
		}
		
		[UIView animateWithDuration:kAnimateFadeDuration
							  delay:kCountDuration
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
							 _unlockedRewardLabel.alpha = 1.0f;
						 }
						 completion:^(BOOL completed) {
							 [UIView animateWithDuration:kAnimateFadeDuration
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

- (IBAction)wrongStoreButtonAction:(id)sender
{
	
}

- (IBAction)exitButtonAction:(id)sender
{
	[self cancelPunchRequest];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
