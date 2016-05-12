//
//  DDCentralCallback.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, ConnectionStatus) {
    ConnectionStatusUnknown = 0,
    ConnectionStatusConnected,
    ConnectionStatusDisconnected,
};

typedef void (^DDCentralBlockDidUpdateCentralState)(CBCentralManagerState state);
typedef void (^DDCentralBlockDidDiscoverPeripheral)(CBPeripheral * __nonnull peripheral);
typedef void (^DDCentralBlockDidStopScan)();
typedef void (^DDCentralBlockConnectionStatus)(CBPeripheral* __nullable peripheral, ConnectionStatus status, NSError * __nullable error);
typedef void (^DDCentralBlockDidDiscoverCharacteristics)(NSArray * __nullable characteristics, NSError *__nullable error);

