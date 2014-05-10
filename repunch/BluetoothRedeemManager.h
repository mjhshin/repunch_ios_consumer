//
//  BluetoothRedeemManager.h
//  RepunchConsumer
//
//  Created by Michael Shin on 5/5/14.
//  Copyright (c) 2014 Repunch. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothRedeemManager : NSObject

@property (assign, nonatomic) CBCentralManagerState state;

+ (BluetoothRedeemManager *)getSharedInstance;
- (void)requestRewardFromStoreWithId:(NSString *)storeId patronStoreId:(NSString *)patronStoreId rewardId:(int)rewardId;
- (void)requestOfferFromStoreWithId:(NSString *)storeId messageStatusId:(NSString *)messageStatusId offerTitle:(NSString *)offerTitle;
- (void)cancelRequest;

@end
