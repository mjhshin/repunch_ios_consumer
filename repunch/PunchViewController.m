//
//  PunchViewController.m
//  BLE Central
//
//  Created by Michael Shin on 4/8/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import "PunchViewController.h"
#import "BluetoothManager.h"

@interface PunchViewController ()

@property (strong, nonatomic) BluetoothManager *bluetoothManager;
@property (assign, nonatomic) BOOL punchRequested;

@end

@implementation PunchViewController

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
	
	_bluetoothManager = [BluetoothManager getSharedInstance];
	_punchRequested = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(bluetoothManagerChangedState)
												 name:kBluetoothNotificationStateChange
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(discoveredStore:)
												 name:kBluetoothNotificationStoreDiscovered
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(receivedPunch:)
												 name:kBluetoothNotificationReceivedPunch
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeConnected)
												 name:kBluetoothNotificationStoreConnected
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(storeDisconnected)
												 name:kBluetoothNotificationStoreDisconnected
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//[self bluetoothManagerChangedState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setViewsForScanning
{
	_titleLabel.text = @"Searching ...";
	_storeNameLabel.hidden = YES;
	_explanationLabel.hidden = YES;
	_wrongStoreButton.hidden = YES;
	_loadingImageView.hidden = NO;
}

- (void)setViewsForPunch
{
	_titleLabel.text = @"Waiting to be punch'd at";
	_storeNameLabel.hidden = NO;
	_explanationLabel.hidden = NO;
	_wrongStoreButton.hidden = NO;
	_loadingImageView.hidden = YES;
}

- (void)requestPunch
{
	_punchRequested = YES;
	[self setViewsForScanning];
	[self bluetoothManagerChangedState];
}

- (void)cancelPunchRequest
{
	_punchRequested = NO;
	[_bluetoothManager cancelRequest];
}

- (void)bluetoothManagerChangedState
{
	if(_bluetoothManager.state == CBCentralManagerStatePoweredOn && _punchRequested) {
		[_bluetoothManager requestPunchesFromNearestStore];
	}
	else if(_bluetoothManager.state == CBCentralManagerStatePoweredOff) {
		
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnauthorized) {
		
	}
	else if(_bluetoothManager.state == CBCentralManagerStateUnsupported) {
		
	}
}

- (void)discoveredStore:(NSNotification *)notification
{
	NSString *storeName = notification.userInfo[@"store"];
	_storeNameLabel.text = storeName;
}

- (void)receivedPunch:(NSNotification *)notification
{
	NSNumber *receivedPunches = notification.userInfo[@"punches"];
	NSLog(@"Received punches");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PunchComplete" object:self userInfo:nil];
}

- (void)storeConnected
{
	[self setViewsForPunch];
}

- (void)storeDisconnected
{
	
}

- (IBAction)wrongStoreButtonAction:(id)sender
{
	
}

@end
