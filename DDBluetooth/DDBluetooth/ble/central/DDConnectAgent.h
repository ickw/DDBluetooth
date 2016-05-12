//
//  DDConnectAgent.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/02.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DDCentralCallback.h"


typedef NS_ENUM(NSUInteger, DDConnectAgentStatus) {
    DDConnectAgentStatusDefault,
    DDConnectAgentStatusConnecting,
    DDConnectAgentStatusDiscovering,
};

@interface DDConnectAgent : NSObject <CBPeripheralDelegate> 

@property (nonatomic) int connectionTrialCount;
@property (nonatomic) int maxConnectionTrialCount;
@property (nonatomic) NSTimeInterval connectionTrialElapsedTime;

- (void)startConnectionWithRetry:(CBPeripheral *)peripheral withMaxRetryCount:(int)maxRetryCount interval:(NSTimeInterval)intervalSeconds didConnect:(DDCentralBlockConnectionStatus)completion;

- (void)discover:(CBPeripheral *)peripheral didDiscover:(DDCentralBlockDidDiscoverCharacteristics)completion;

- (void)disconnect:(DDCentralBlockConnectionStatus)completion;

@end
