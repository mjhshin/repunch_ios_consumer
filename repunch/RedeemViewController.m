//
//  RedeemViewController.m
//  RepunchConsumer
//
//  Created by Michael Shin on 5/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "RedeemViewController.h"
#import "BluetoothRedeemManager.h"
#import "RepunchUtils.h"
#import "RPConstants.h"
#import "DataManager.h"

#define kAnimateDelay 0.5f
#define kAnimateFadeDuration 0.3f
#define kCountDuration 0.8f

@interface RedeemViewController ()

@property (strong, nonatomic) BluetoothRedeemManager *bluetoothManager;
@property (assign, nonatomic) BOOL redeemRequested;
@property (strong, nonatomic) RPPatronStore *patronStore;
@property (strong, nonatomic) RPMessageStatus *messageStatus;
@property (strong, nonatomic) NSString *rewardTitle;
@property (assign, nonatomic) int rewardPunches;
@property (assign, nonatomic) int oldPunchCount;

@end

@implementation RedeemViewController

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
	
	_bluetoothManager = [BluetoothRedeemManager getSharedInstance];
	_redeemRequested = NO;
	RPStore *store = [[DataManager getSharedInstance] getStore:_storeId];
	_storeNameLabel.text = store.store_name;
	
	if(_patronStoreId) {
		_patronStore = [[DataManager getSharedInstance] getPatronStore:_storeId];
	
		for(id reward in store.rewards) {
			if([reward[@"reward_id"] intValue] == _rewardId) {
				_rewardTitle = reward[@"reward_name"];
				_rewardPunches = [reward[@"punches"] intValue];
			}
		}
	}
	else {
		_messageStatus = [[DataManager getSharedInstance] getMessage:_messageStatusId];
		_rewardTitle = (_messageStatus.Message.type == RPMessageTypeOffer) ? _messageStatus.Message.offer_title : _messageStatus.Message.gift_title;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkBluetoothManagerState)
												 name:kNotificationBluetoothStateChange
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeConnected)
												 name:kNotificationBluetoothStoreConnected
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeDisconnected)
												 name:kNotificationBluetoothStoreDisconnected
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redeemApproved)
												 name:kNotificationBluetoothRedeemApproved
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redeemRejected)
												 name:kNotificationBluetoothRedeemRejected
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
	
	[self requestRedeem];
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
	
	_resultLabel.text = [NSString stringWithFormat:@"Redeemed reward\n'%@'", _rewardTitle];
	
	_radarView.hidden = YES;
	_statusImageView.hidden = YES;
	_statusLabel.hidden = YES;
	_storeNameLabel.hidden = YES;
	_resultView.hidden = YES;
	
	_storeNameLabel.textColor = [RepunchUtils repunchOrangeColor];
	_punchCountLabel.textColor = [RepunchUtils repunchOrangeColor];
}

- (void)setViewsForScanning
{
	_radarView.hidden = NO;
	_statusLabel.text = @"Connecting...";
	_statusLabel.hidden = NO;
	_statusImageView.hidden = YES;
	_storeNameLabel.hidden = NO;
	_resultView.hidden = YES;
	
	[_radarView startAnimation];
}

- (void)setViewsForApproval
{
	_radarView.hidden = YES;
	_statusLabel.hidden = YES;
	_statusImageView.hidden = YES;
	_storeNameLabel.hidden = NO;
	_resultView.hidden = NO;
	
	[_radarView stopAnimation];
	
	_resultLabel.alpha = 0.0f;
	_punchCountView.alpha = 0.0f;
}

- (void)checkBluetoothManagerState
{
	if(_bluetoothManager.state == CBCentralManagerStatePoweredOn && _redeemRequested) {
		[self setViewsForScanning];
		
		if(_patronStoreId) {
			[_bluetoothManager requestRewardFromStoreWithId:_storeId
											  patronStoreId:_patronStoreId
												   rewardId:_rewardId];
		}
		else {
			[_bluetoothManager requestOfferFromStoreWithId:_storeId
										   messageStatusId:_messageStatusId
												offerTitle:_rewardTitle];
		}
	}
	else if(_bluetoothManager.state == CBCentralManagerStatePoweredOff) {
		[self bluetoothOff];
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnauthorized) {
		//prompt to authorize
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnsupported) {
		//error
	}
}

- (void)requestRedeem
{
	_redeemRequested = YES;
	[self checkBluetoothManagerState];
}

- (void)cancelRedeemRequest
{
	_redeemRequested = NO;
	[_bluetoothManager cancelRequest];
}

- (void)redeemApproved
{
	[self setViewsForApproval];
	
	_redeemRequested = NO;
	
	if(_patronStoreId) {
		_oldPunchCount = _patronStore.punch_count;
		_patronStore.punch_count -= _rewardPunches;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPunch object:self];
	}
	else {
		[_messageStatus setObject:@"no" forKey:@"redeem_available"];
	}
	
	[UIView animateWithDuration:kAnimateFadeDuration
						  delay:kAnimateDelay
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _resultLabel.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 if(_patronStoreId) {
							 [self showPunchCountView];
						 }
					 }];
}

- (void)showPunchCountView
{
	_punchCountLabel.format = @"%d";
	_punchCountLabel.method = UILabelCountingMethodLinear;
	_punchCountLabel.text = [NSString stringWithFormat:@"%i", _oldPunchCount];
	
	[UIView animateWithDuration:kAnimateFadeDuration
						  delay:kAnimateDelay
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 _punchCountView.alpha = 1.0f;
					 }
					 completion:^(BOOL completed) {
						 [_punchCountLabel countFrom:_oldPunchCount
												  to:_oldPunchCount - _rewardPunches
										withDuration:kCountDuration];
					 }];
}

- (void)redeemRejected
{
	_redeemRequested = NO;
	
	[self cancelRedeemRequest];
	
	_statusLabel.text = @"The store said no.";
	_statusImageView.image = [UIImage imageNamed:@"BluetoothDisconnected"];
	
	[self setViewsForError];
}

- (void)storeConnected
{
	_radarView.hidden = NO;
	_statusLabel.text = [NSString stringWithFormat:@"Requesting\n'%@'", _rewardTitle];
	_statusLabel.hidden = NO;
	_statusImageView.hidden = YES;
	_storeNameLabel.hidden = NO;
	_resultView.hidden = YES;
	
	//[_radarView stopAnimation];
}

- (void)storeDisconnected
{
	if(_redeemRequested) {
		[self cancelRedeemRequest];
		[self bluetoothError];
	}
}

- (void)storeNotFound
{
	_statusLabel.text = @"It doesn't seem like you're \n near this store.";
	_statusImageView.image = [UIImage imageNamed:@"BluetoothTimeout"];
	
	[self setViewsForError];
}

- (void)bluetoothError
{
	_statusLabel.text = @"Sorry, something went wrong.";
	_statusImageView.image = [UIImage imageNamed:@"BluetoothError"];
	
	[self setViewsForError];
}

- (void)bluetoothOff
{
	_statusLabel.text = @"Please enable Bluetooth \n to use this feature.";
	_statusImageView.image = [UIImage imageNamed:@"BluetoothOff"];
	
	[self setViewsForError];
}

- (void)setViewsForError
{
	_radarView.hidden = YES;
	_statusImageView.hidden = NO;
	_statusLabel.hidden = NO;
	_storeNameLabel.hidden = YES;
	_resultView.hidden = YES;
	
	[_radarView stopAnimation];
}

- (IBAction)exitButtonAction:(id)sender
{
	[self cancelRedeemRequest];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
