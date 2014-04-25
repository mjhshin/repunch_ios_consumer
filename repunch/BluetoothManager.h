//
//  BluetoothManager.h
//  BLE Central
//
//  Created by Michael Shin on 4/3/14.
//  Copyright (c) 2014 Repunch, Inc. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothManager : NSObject

@property (assign, nonatomic) CBCentralManagerState state;

+ (BluetoothManager *)getSharedInstance;
- (void)requestPunchesFromNearestStore;
- (void)cancelRequest;

@end
