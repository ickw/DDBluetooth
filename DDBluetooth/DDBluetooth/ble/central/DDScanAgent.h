//
//  DDScanAgent.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCentralCallback.h"

@interface DDScanAgent : NSObject

@property (nonatomic) BOOL isScanning;

- (void)startScanForServices:(NSArray<CBUUID *> *)services withPrefixes:(NSArray<NSString *> *)prefixes interval:(NSTimeInterval)interval found:(void(^)(CBPeripheral *peripheral))found stop:(DDCentralBlockDidStopScan)stop;

- (void)stopScan;

- (void)clear;

@end
