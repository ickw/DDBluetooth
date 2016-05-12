//
//  CBPeripheral+DD.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/02.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (DD)

@property (nonatomic, strong) NSNumber *foundRSSI;
@property (nonatomic, copy) NSArray<CBUUID *> *serviceUUIDs;
@property (nonatomic, copy) NSString *localName;

/*
 * Characteristics
 */
@property (nonatomic, strong) CBCharacteristic *characteristicIndication;
@property (nonatomic, strong) CBCharacteristic *characteristicWrite;
@property (nonatomic, strong) CBCharacteristic *characteristicRead;

- (void)clearCharacteristics;

@end
