//
//  DDScannedPeripherals.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/30.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CBPeripheral;

@interface DDScannedPeripherals : NSObject

+ (DDScannedPeripherals *)sharedPeripherals;
- (void)initialize;
- (void)addPeripheral:(CBPeripheral *)peripheral;
- (void)clear;
- (BOOL)isExist:(CBPeripheral *)peripheral;
- (NSArray *)getRssiSortedPeripherals;
- (NSUInteger)count;

@end
