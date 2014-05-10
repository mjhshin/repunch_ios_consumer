//
//  BluetoothRedeemManager.m
//  RepunchConsumer
//
//  Created by Michael Shin on 5/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import "BluetoothRedeemManager.h"
#import "BluetoothConstants.h"
#import "DataManager.h"
#import "RPConstants.h"

@interface BluetoothRedeemManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

@property (strong, nonatomic) CBUUID *UUIDServiceRedeem;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicStoreId;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicPatronName;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicPatronStoreId;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicRewardId;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicMessageStatusId;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicOfferTitle;
@property (strong, nonatomic) CBUUID *UUIDCharacteristicApproval;

@property (strong, nonatomic) CBCharacteristic *characteristicPatronName;
@property (strong, nonatomic) CBCharacteristic *characteristicPatronStoreId;
@property (strong, nonatomic) CBCharacteristic *characteristicRewardId;
@property (strong, nonatomic) CBCharacteristic *characteristicMessageStatusId;
@property (strong, nonatomic) CBCharacteristic *characteristicOfferTitle;
@property (strong, nonatomic) CBCharacteristic *characteristicApproval;

@property (strong, nonatomic) NSMutableArray *wrongPeripherals;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *storeId;
@property (strong, nonatomic) NSString *patronStoreId;
@property (assign, nonatomic) int rewardId;
@property (strong, nonatomic) NSString *messageStatusId;
@property (strong, nonatomic) NSString *offerTitle;

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSOperation *operationReadStoreId;
@property (strong, nonatomic) NSOperation *operationWritePatronName;
@property (strong, nonatomic) NSOperation *operationWritePatronStoreId;
@property (strong, nonatomic) NSOperation *operationWriteRewardId;
@property (strong, nonatomic) NSOperation *operationWriteMessageStatusId;
@property (strong, nonatomic) NSOperation *operationWriteOfferTitle;
@property (strong, nonatomic) NSOperation *operationRequestNotifyApproval;
@property (strong, nonatomic) NSOperation *operationSetNotifyApproval;

@end

@implementation BluetoothRedeemManager

static BluetoothRedeemManager *sharedBluetoothManager = nil;

+ (BluetoothRedeemManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
        sharedBluetoothManager = [[BluetoothRedeemManager alloc] init];
    });
    return sharedBluetoothManager;
}

- (id)init
{
	if (self = [super init])
	{
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		_state = CBCentralManagerStateUnknown;
		
		_UUIDServiceRedeem						= [CBUUID UUIDWithString:kUUIDServiceRedeem];
		_UUIDCharacteristicStoreId				= [CBUUID UUIDWithString:kUUIDCharacteristicStoreId];
		_UUIDCharacteristicPatronName			= [CBUUID UUIDWithString:kUUIDCharacteristicPatronName];
		_UUIDCharacteristicPatronStoreId		= [CBUUID UUIDWithString:kUUIDCharacteristicPatronStoreId];
		_UUIDCharacteristicRewardId				= [CBUUID UUIDWithString:kUUIDCharacteristicRewardId];
		_UUIDCharacteristicMessageStatusId		= [CBUUID UUIDWithString:kUUIDCharacteristicMessageStatusId];
		_UUIDCharacteristicOfferTitle			= [CBUUID UUIDWithString:kUUIDCharacteristicOfferTitle];
		_UUIDCharacteristicApproval				= [CBUUID UUIDWithString:kUUIDCharacteristicApproval];
		
		_wrongPeripherals = [NSMutableArray array];
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"BluetoothPunchManager dealloc'd");
}

- (void)requestRewardFromStoreWithId:(NSString *)storeId patronStoreId:(NSString *)patronStoreId rewardId:(int)rewardId
{
	_storeId = storeId;
	_patronStoreId = patronStoreId;
	_rewardId = rewardId;
	
	[self startScan];
}

- (void)requestOfferFromStoreWithId:(NSString *)storeId messageStatusId:(NSString *)messageStatusId offerTitle:(NSString *)offerTitle;
{
	_storeId = storeId;
	_messageStatusId = messageStatusId;
	_offerTitle = offerTitle;
	
	[self startScan];
}

- (void)cancelRequest
{
	if(_connectedPeripheral != nil) {
		NSLog(@"Cancel connection");
		[_centralManager cancelPeripheralConnection:_connectedPeripheral];
	}
}

// ========================================================
// CBCentralManagerDelegate
// ========================================================

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	_state = central.state;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothStateChange
														object:self
													  userInfo:nil];
	
	switch(_state)
	{
		case CBCentralManagerStatePoweredOn:
			break;
			
		case CBCentralManagerStateResetting:
			//The connection with the system service was momentarily lost; an update is imminent.
			break;
			
		case CBCentralManagerStateUnauthorized:
			//The app is not authorized to use Bluetooth low energy.
			break;
			
		case CBCentralManagerStatePoweredOff:
			//Bluetooth is currently powered off.
			break;
			
		case CBCentralManagerStateUnknown:
			//The current state of the central manager is unknown; an update is imminent.
			break;
			
		case CBCentralManagerStateUnsupported:
			//The platform does not support Bluetooth low energy.
			break;
			
		default:
			break;
	}
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
	 advertisementData:(NSDictionary *)advertisementData
				  RSSI:(NSNumber *)RSSI
{
	// Reject any where the value is above reasonable range
    //if (RSSI.integerValue > -15) {
    //    return;
    //}
	
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    //if (RSSI.integerValue < -35) {
    //    return;
    //}
	NSLog(@"Discovered %@ with RSSI: %@", peripheral.name, RSSI);
	
	if (_connectedPeripheral != peripheral) {
		NSLog(@"Connecting to peripheral %@", peripheral);
		_connectedPeripheral = peripheral; //otherwise gets dealloc'd while connecting
		[_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	NSLog(@"Peripheral Connected");
	[_centralManager stopScan];
	NSLog(@"Scanning stopped");
	peripheral.delegate = self;
	[peripheral discoverServices:@[_UUIDServiceRedeem]];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
				 error:(NSError *)error
{
	NSLog(@"Disconnected peripheral %@. (%@)", peripheral, error.localizedDescription);
	_connectedPeripheral = nil;
	[self notifyPeripheralDisconnected];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
				 error:(NSError *)error
{
	NSLog(@"Failed to connect to %@. (%@)", peripheral, error.localizedDescription);
	[self handleError];
}

// ========================================================
// CBPeripheralDelegate
// ========================================================

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (error) {
        NSLog(@"Error discovering services: %@", error.localizedDescription);
        [self handleError];
        return;
    }
	
	for (CBService *service in peripheral.services)
	{
		if(_patronStoreId)
		{
			[peripheral discoverCharacteristics:@[_UUIDCharacteristicStoreId,
												  _UUIDCharacteristicPatronName,
												  _UUIDCharacteristicPatronStoreId,
												  _UUIDCharacteristicRewardId,
												  _UUIDCharacteristicApproval]
									 forService:service];
		}
		else
		{
			[peripheral discoverCharacteristics:@[_UUIDCharacteristicStoreId,
												  _UUIDCharacteristicPatronName,
												  _UUIDCharacteristicMessageStatusId,
												  _UUIDCharacteristicOfferTitle,
												  _UUIDCharacteristicApproval]
									 forService:service];
		}
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
			 error:(NSError *)error
{
	if (error) {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        [self handleError];
        return;
    }
	
	NSLog(@"Discovered characteristics");
	for (CBCharacteristic *characteristic in service.characteristics)
	{
		if ([characteristic.UUID isEqual:_UUIDCharacteristicStoreId])
		{
			NSLog(@"Discovered store id");
			[peripheral readValueForCharacteristic:characteristic];
        }
		else if ([characteristic.UUID isEqual:_UUIDCharacteristicPatronName])
		{
			NSLog(@"Discovered patronstore id");
			_characteristicPatronName = characteristic;
			[_operationQueue addOperation:_operationWritePatronName];
        }
        else if ([characteristic.UUID isEqual:_UUIDCharacteristicPatronStoreId])
		{
			NSLog(@"Discovered patronstore id");
			_characteristicPatronStoreId = characteristic;
			[_operationQueue addOperation:_operationWritePatronStoreId];
        }
		else if([characteristic.UUID isEqual:_UUIDCharacteristicRewardId])
		{
			NSLog(@"Discovered reward id");
			_characteristicRewardId = characteristic;
			[_operationQueue addOperation:_operationWriteRewardId];
		}
		else if([characteristic.UUID isEqual:_UUIDCharacteristicMessageStatusId])
		{
			NSLog(@"Discovered msg status id");
			_characteristicMessageStatusId = characteristic;
			[_operationQueue addOperation:_operationWriteMessageStatusId];
		}
		else if([characteristic.UUID isEqual:_UUIDCharacteristicOfferTitle])
		{
			NSLog(@"Discovered offer title");
			_characteristicOfferTitle = characteristic;
			[_operationQueue addOperation:_operationWriteOfferTitle];
		}
		else if([characteristic.UUID isEqual:_UUIDCharacteristicApproval])
		{
			NSLog(@"Discovered approval");
			_characteristicApproval = characteristic;
			[_operationQueue addOperation:_operationRequestNotifyApproval];
		}
		else
		{
			NSLog(@"Unknown characteristic found");
		}
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error
{
	NSLog(@"Characteristic UUID: %@", characteristic.UUID.UUIDString);
	if (error) {
        NSLog(@"Error reading characteristic: %@", error.localizedDescription);
		//[self handleError];
        return;
    }
	
	if([characteristic.UUID isEqual:_UUIDCharacteristicStoreId])
	{
		NSString *discoveredStoreId = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
		NSLog(@"Read store ID characteristic: %@", _storeId);
		
		if([_storeId isEqualToString:discoveredStoreId]) {
			[_operationQueue addOperation:_operationReadStoreId];
		}
	}
	else if([characteristic.UUID isEqual:_UUIDCharacteristicApproval])
	{
		// Expecting 32 bits - hence we use int (32-bit) and not NSInteger (platform-dependent)
		NSData *data = [characteristic.value subdataWithRange:NSMakeRange(0, 4)];
		int reverseEndianValue = *(int *)([data bytes]);
		
		NSLog(@"Read approval characteristic: %i", reverseEndianValue);
		
		// +1 for approved. -1 means rejected.
		if(reverseEndianValue > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothRedeemApproved
																object:self
															  userInfo:nil];
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothRedeemRejected
																object:self
															  userInfo:nil];
		}
		
		[_centralManager cancelPeripheralConnection:peripheral];
		[self notifyPeripheralDisconnected];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error
{
	if (error) {
        NSLog(@"Error writing characteristic: %@", error.localizedDescription);
		//[self handleError];
		return;
    }
	NSLog(@"Wrote characteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error
{
	if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
		[self handleError];
		return;
    }
	
	NSLog(@"Set notify for approval characteristic");
	[_operationQueue addOperation:_operationSetNotifyApproval];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
	NSLog(@"Peripheral didModifyServices");
	/*
	 Invoked when a peripheral’s services have changed.
	 
	 1) A service is removed from the peripheral’s database
	 2) A new service is added to the peripheral’s database
	 3) A service that was previously removed from the peripheral’s database is re-added to the database at a different location
	 
	 If you previously discovered any of the services that have changed, they are provided in the invalidatedServices
	 parameter and can no longer be used. You can use the discoverServices: method to discover any new services that
	 have been added to the peripheral’s database or to find out whether any of the invalidated services that you were
	 using (and want to continue using) have been added back to a different location in the peripheral’s database.
	 */
}

- (void)startScan
{
	[_centralManager scanForPeripheralsWithServices:@[_UUIDServiceRedeem] options:nil];
    
    NSLog(@"Scanning started");
	_timer = [NSTimer scheduledTimerWithTimeInterval:kBluetoothScanTimeoutInterval
											  target:self
											selector:@selector(scanningTimeout)
											userInfo:nil
											 repeats:NO];
	[self initOperations];
}

- (void)notifyPeripheralConnected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothStoreConnected
														object:self
													  userInfo:nil];
}

- (void)notifyPeripheralDisconnected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothStoreDisconnected
														object:self
													  userInfo:nil];
}

- (void)scanningTimeout
{
	[_centralManager stopScan];
	[self cleanup];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothScanTimeout
														object:self
													  userInfo:nil];
}

- (void)handleError
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothError
														object:self
													  userInfo:nil];
	
	[self cleanup];
}

- (void)cleanup
{
	[_timer invalidate];
	
	_storeId = nil;
	_patronStoreId = nil;
	_messageStatusId = nil;
	
	_connectedPeripheral = nil;
	_wrongPeripherals = nil;
	
	_operationQueue = nil;
	_operationReadStoreId = nil;
	_operationWritePatronName = nil;
	_operationWritePatronStoreId = nil;
	_operationWriteRewardId = nil;
	_operationWriteMessageStatusId = nil;
	_operationRequestNotifyApproval = nil;
	_operationSetNotifyApproval = nil;
}

- (void)initOperations
{
	__weak typeof(self) weakSelf = self;
	
	_operationQueue					= [[NSOperationQueue alloc] init];
	
	_operationReadStoreId			= [NSBlockOperation blockOperationWithBlock:^{}];
	_operationSetNotifyApproval		= [NSBlockOperation blockOperationWithBlock:^{}];
	
	// Wait on writing or subscribing to characteristics until correct storeId has been read
	_operationWritePatronName		= [NSBlockOperation blockOperationWithBlock:^{
		RPPatron *patron = [[DataManager getSharedInstance] patron];
		NSData* data = [patron.full_name dataUsingEncoding:NSUTF8StringEncoding];
		[weakSelf.connectedPeripheral writeValue:data
							   forCharacteristic:_characteristicPatronName
											type:CBCharacteristicWriteWithResponse];
	}];
	[_operationWritePatronName addDependency:_operationReadStoreId];
	
	_operationRequestNotifyApproval		= [NSBlockOperation blockOperationWithBlock:^{
		[weakSelf.connectedPeripheral setNotifyValue:YES forCharacteristic:_characteristicApproval];
	}];
	[_operationRequestNotifyApproval addDependency:_operationReadStoreId];
	
	if(_patronStoreId)
	{
		_operationWritePatronStoreId	= [NSBlockOperation blockOperationWithBlock:^{
			NSData* data = [weakSelf.patronStoreId dataUsingEncoding:NSUTF8StringEncoding];
			[weakSelf.connectedPeripheral writeValue:data
								   forCharacteristic:_characteristicPatronStoreId
												type:CBCharacteristicWriteWithResponse];
		}];
		[_operationWritePatronStoreId addDependency:_operationReadStoreId];
		
		_operationWriteRewardId			= [NSBlockOperation blockOperationWithBlock:^{
			int rewardId = weakSelf.rewardId;
			NSData *data = [NSData dataWithBytes: &rewardId length: sizeof(rewardId)];
			[weakSelf.connectedPeripheral writeValue:data
								   forCharacteristic:_characteristicRewardId
												type:CBCharacteristicWriteWithResponse];
		}];
		[_operationWriteRewardId addDependency:_operationReadStoreId];
	}
	else
	{
		_operationWriteMessageStatusId	= [NSBlockOperation blockOperationWithBlock:^{
			NSData* data = [weakSelf.messageStatusId dataUsingEncoding:NSUTF8StringEncoding];
			[weakSelf.connectedPeripheral writeValue:data
								   forCharacteristic:_characteristicMessageStatusId
												type:CBCharacteristicWriteWithResponse];
		}];
		[_operationWriteMessageStatusId addDependency:_operationReadStoreId];
		
		_operationWriteOfferTitle	= [NSBlockOperation blockOperationWithBlock:^{
			NSData* data = [weakSelf.offerTitle dataUsingEncoding:NSUTF8StringEncoding];
			[weakSelf.connectedPeripheral writeValue:data
								   forCharacteristic:_characteristicOfferTitle
												type:CBCharacteristicWriteWithResponse];
		}];
		[_operationWriteOfferTitle addDependency:_operationReadStoreId];
	}
	
	// Wait on broadcasting store connection until all characteristics read
	NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[weakSelf.timer invalidate];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothStoreConnected
																object:weakSelf
															  userInfo:nil];
		}];
	}];
	
	[operation addDependency:_operationReadStoreId];
	[operation addDependency:_operationSetNotifyApproval];
	
	[_operationQueue addOperation:operation];
}

@end
