//
//  BluetoothManager.m
//  BLE Central
//
//  Created by Michael Shin on 4/3/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import "BluetoothManager.h"
#import "BluetoothConstants.h"

@interface BluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectedPeripheral;

@property (strong, nonatomic) CBUUID *UUIDserviceStore;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicStoreName;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicCustomerName;
@property (strong, nonatomic) CBUUID *UUIDcharacteristicPunch;

@property (strong, nonatomic) CBCharacteristic *characteristicCustomerName;
@property (strong, nonatomic) CBCharacteristic *characteristicPunch;

@property (strong, nonatomic) NSMutableArray *wrongPeripherals;

@property (assign, nonatomic) BOOL customerNameSent;
@property (assign, nonatomic) BOOL storeNameRead;
@property (assign, nonatomic) BOOL punchCountSubscribed;

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
		_UUIDcharacteristicStoreName = [CBUUID UUIDWithString:kUUIDCharacteristicStoreName];
		_UUIDcharacteristicCustomerName = [CBUUID UUIDWithString:kUUIDCharacteristicCustomerName];
		_UUIDcharacteristicPunch = [CBUUID UUIDWithString:kUUIDCharacteristicPunch];
		
		_wrongPeripherals = [NSMutableArray array];
		
		_customerNameSent = NO;
		_storeNameRead = NO;
		_punchCountSubscribed = NO;
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
}

- (void)sendWriteRquestForName
{
	NSString *name = @"Neil deGrasse Tyson";
	NSData* data = [name dataUsingEncoding:NSUTF8StringEncoding];
	[_connectedPeripheral writeValue:data
				   forCharacteristic:_characteristicCustomerName
								type:CBCharacteristicWriteWithResponse];
}

- (void)subscribeForPunches
{
	[_connectedPeripheral setNotifyValue:YES forCharacteristic:_characteristicPunch];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothNotificationStoreConnected
														object:self
													  userInfo:nil];
}

- (void)notifyPeripheralDisconnected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothNotificationStoreDisconnected
														object:self
													  userInfo:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	_state = central.state;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothNotificationStateChange
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
	//[self cleanup];
}





// ========================================================
// CBPeripheralDelegate
// ========================================================

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (error) {
        NSLog(@"Error discovering services: %@", error.localizedDescription);
        //[self cleanup];
        return;
    }
	
	for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[_UUIDcharacteristicStoreName,
											  _UUIDcharacteristicCustomerName,
											  _UUIDcharacteristicPunch]
								 forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
			 error:(NSError *)error
{
	if (error) {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        //[self cleanup];
        return;
    }
	
	for (CBCharacteristic *characteristic in service.characteristics)
	{
        if ([characteristic.UUID isEqual:_UUIDcharacteristicStoreName])
		{
			[peripheral readValueForCharacteristic:characteristic];
        }
		else if([characteristic.UUID isEqual:_UUIDcharacteristicCustomerName])
		{
			_characteristicCustomerName = characteristic;
			[self sendWriteRquestForName];
		}
		else if([characteristic.UUID isEqual:_UUIDcharacteristicPunch])
		{
			_characteristicPunch = characteristic;
			[self subscribeForPunches];
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
	if (error) {
        NSLog(@"Error reading characteristic: %@", error.localizedDescription);
        return;
    }
	
	if([characteristic.UUID isEqual:_UUIDcharacteristicStoreName])
	{
		NSLog(@"Read store name characteristic");
		_storeNameRead = YES;
		
		NSString *storeName = [[NSString alloc] initWithData:characteristic.value
													encoding:NSUTF8StringEncoding];
		
		NSDictionary *dataDict = [NSDictionary dictionaryWithObject:storeName
															 forKey:@"store_name"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothNotificationStoreDiscovered
															object:self
														  userInfo:dataDict];
	}
	else if([characteristic.UUID isEqual:_UUIDcharacteristicPunch])
	{
		NSLog(@"Read punch characteristic");
		
		NSData *data = [characteristic.value subdataWithRange:NSMakeRange(0, 4)];
		int value = CFSwapInt32BigToHost(*(int *)([data bytes]));
		int reverseEndianValue = *(int *)([data bytes]);
		NSLog(@"4 byte value: %i", value);
		NSLog(@"4 byte value (reverse endian): %i", reverseEndianValue);
		NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:reverseEndianValue]
															 forKey:@"punches"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothNotificationReceivedPunch
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
		return;
    }
	NSLog(@"Wrote customer name characteristic");
	
	_customerNameSent = YES;
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error
{
	if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
		return;
    }
	
	NSLog(@"Set notify for punch characteristic");
	
	_punchCountSubscribed = YES;
	
	[self notifyPeripheralConnected];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
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

@end








