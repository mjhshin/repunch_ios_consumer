//
//  BluetoothManager.m
//  BLE Central
//
//  Created by Michael Shin on 4/3/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import "BluetoothManager.h"
#import "BluetoothConstants.h"
#import "DataManager.h"
#import "RPConstants.h"

@interface BluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

@property (strong, nonatomic) CBUUID *UUIDserviceStore;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicStoreId;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicStoreName;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicPatronId;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicPatronName;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicPunch;

@property (strong, nonatomic) NSMutableArray *wrongPeripherals;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *storeId;
@property (strong, nonatomic) NSString *storeName;

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSOperation *operationReadStoreId;
@property (strong, nonatomic) NSOperation *operationReadStoreName;
@property (strong, nonatomic) NSOperation *operationSubscribePunch;

@end

@implementation BluetoothManager

static BluetoothManager *sharedBluetoothManager = nil;

+ (BluetoothManager *)getSharedInstance
{
    static dispatch_once_t onceToken;
	
    dispatch_once(&onceToken, ^{
        sharedBluetoothManager = [[BluetoothManager alloc] init];
    });
    return sharedBluetoothManager;
}

- (id)init
{
	if (self = [super init])
	{
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		_state = CBCentralManagerStateUnknown;
		
		_UUIDserviceStore = [CBUUID UUIDWithString:kUUIDServiceStore];
		_UUIDcharacteristicStoreId = [CBUUID UUIDWithString:kUUIDCharacteristicStoreId];
		_UUIDcharacteristicStoreName = [CBUUID UUIDWithString:kUUIDCharacteristicStoreName];
		_UUIDcharacteristicPatronId = [CBUUID UUIDWithString:kUUIDCharacteristicPatronId];
		_UUIDcharacteristicPatronName = [CBUUID UUIDWithString:kUUIDCharacteristicPatronName];
		_UUIDcharacteristicPunch = [CBUUID UUIDWithString:kUUIDCharacteristicPunch];
		
		_wrongPeripherals = [NSMutableArray array];
	}
	
	return self;
}

- (void)dealloc
{
	NSLog(@"BluetoothManager dealloc'd");
}

- (void)requestPunchesFromNearestStore
{
    [_centralManager scanForPeripheralsWithServices:@[_UUIDserviceStore]
											options:nil];
    
    NSLog(@"Scanning started");
	_timer = [NSTimer scheduledTimerWithTimeInterval:kBluetoothScanTimeoutInterval
											  target:self
											selector:@selector(scanningTimeout)
											userInfo:nil
											 repeats:NO];
	[self initOperations];
}

- (void)writePatronNameCharacteristic:(CBCharacteristic *)characteristic
{
	RPPatron *patron = [[DataManager getSharedInstance] patron];
	NSData* data = [patron.full_name dataUsingEncoding:NSUTF8StringEncoding];
	[_connectedPeripheral writeValue:data
				   forCharacteristic:characteristic
								type:CBCharacteristicWriteWithResponse];
}

- (void)writePatronIdCharacteristic:(CBCharacteristic *)characteristic
{
	RPPatron *patron = [[DataManager getSharedInstance] patron];
	NSData* data = [patron.objectId dataUsingEncoding:NSUTF8StringEncoding];
	[_connectedPeripheral writeValue:data
				   forCharacteristic:characteristic
								type:CBCharacteristicWriteWithResponse];
}

- (void)subscribeToPunchesCharacteristic:(CBCharacteristic *)characteristic
{
	[_connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)cancelRequest
{
	if(_connectedPeripheral != nil) {
		NSLog(@"Cancel connection");
		[_centralManager cancelPeripheralConnection:_connectedPeripheral];
	}
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


// ========================================================
// CBCentralManagerDelegate
// ========================================================

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
	[peripheral discoverServices:@[_UUIDserviceStore]];
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
	
	for (CBService *service in peripheral.services) {
		if([service.UUID isEqual:_UUIDserviceStore]) {
			[peripheral discoverCharacteristics:@[_UUIDcharacteristicStoreId,
												  _UUIDcharacteristicStoreName,
												  _UUIDcharacteristicPatronId,
												  _UUIDcharacteristicPatronName,
												  _UUIDcharacteristicPunch]
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
		if ([characteristic.UUID isEqual:_UUIDcharacteristicStoreId])
		{
			NSLog(@"Discovered store id");
			[peripheral readValueForCharacteristic:characteristic];
        }
        else if ([characteristic.UUID isEqual:_UUIDcharacteristicStoreName])
		{
			NSLog(@"Discovered store name");
			[peripheral readValueForCharacteristic:characteristic];
        }
		else if([characteristic.UUID isEqual:_UUIDcharacteristicPatronId])
		{
			NSLog(@"Discovered patron id");
			[self writePatronIdCharacteristic:characteristic];
		}
		else if([characteristic.UUID isEqual:_UUIDcharacteristicPatronName])
		{
			NSLog(@"Discovered patron name");
			[self writePatronNameCharacteristic:characteristic];
		}
		else if([characteristic.UUID isEqual:_UUIDcharacteristicPunch])
		{
			NSLog(@"Discovered punch");
			[self subscribeToPunchesCharacteristic:characteristic];
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
	
	if([characteristic.UUID isEqual:_UUIDcharacteristicStoreId])
	{
		_storeId = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
		NSLog(@"Read store ID characteristic: %@", _storeId);
		[_operationQueue addOperation:_operationReadStoreId];
	}
	else if([characteristic.UUID isEqual:_UUIDcharacteristicStoreName])
	{
		_storeName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
		NSLog(@"Read store name characteristic: %@", _storeName);
		[_operationQueue addOperation:_operationReadStoreName];
	}
	else if([characteristic.UUID isEqual:_UUIDcharacteristicPunch])
	{
		NSLog(@"Read punch characteristic");
		
		NSData *data = [characteristic.value subdataWithRange:NSMakeRange(0, 4)]; //need to handle different range
		//int value = CFSwapInt32BigToHost(*(int *)([data bytes]));
		//NSLog(@"4 byte value: %i", value);
		int reverseEndianValue = *(int *)([data bytes]);
		NSLog(@"4 byte value (reverse endian): %i", reverseEndianValue);
		NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:reverseEndianValue]
															 forKey:kNotificationBluetoothPunches];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothReceivedPunch
															object:self
														  userInfo:dataDict];
		
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
	
	NSLog(@"Set notify for punch characteristic");
	[_timer invalidate];
	[_operationQueue addOperation:_operationSubscribePunch];
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
	
	_connectedPeripheral = nil;
	_wrongPeripherals = nil;
	
	_operationQueue = nil;
	_operationReadStoreId = nil;
	_operationReadStoreName = nil;
	_operationSubscribePunch = nil;
}

- (void)initOperations
{
	_operationQueue = [[NSOperationQueue alloc] init];
	
	NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			
			NSDictionary *dataDict = @{kNotificationBluetoothStoreId	: _storeId,
									   kNotificationBluetoothStoreName	: _storeName};
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBluetoothStoreConnected
																object:self
															  userInfo:dataDict];
		}];
	}];
	
	_operationReadStoreId = [NSBlockOperation blockOperationWithBlock:^{}];
	_operationReadStoreName = [NSBlockOperation blockOperationWithBlock:^{}];
	_operationSubscribePunch = [NSBlockOperation blockOperationWithBlock:^{}];
	
	[operation addDependency:_operationReadStoreId];
	[operation addDependency:_operationReadStoreName];
	[operation addDependency:_operationSubscribePunch];
	
	[_operationQueue addOperation:operation];
}

@end








