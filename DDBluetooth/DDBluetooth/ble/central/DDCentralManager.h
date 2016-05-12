//
//  DDCentralManager.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DDCentralCallback.h"

@interface DDCentralManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, assign) ConnectionStatus connectionStatus;

+ (DDCentralManager *)sharedManager;

- (void)initialize:(dispatch_queue_t)queue options:(NSDictionary *)options didInitialize:(DDCentralBlockDidUpdateCentralState)completion;

- (void)terminate;

- (void)startScan:(NSArray *)serviceUUID didDiscoverPeripheral: (DDCentralBlockDidDiscoverPeripheral)completion;

- (void)stopScan;

- (void)connect:(CBPeripheral *)peripheral didConnect:(DDCentralBlockConnectionStatus)completion;

- (void)disconnect:(CBPeripheral *)peripheral didDisconnect:(DDCentralBlockConnectionStatus)completion;

- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;

@end
