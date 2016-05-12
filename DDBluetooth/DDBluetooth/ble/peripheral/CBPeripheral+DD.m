//
//  CBPeripheral+DD.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/02.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "CBPeripheral+DD.h"
#import <objc/runtime.h>

@implementation CBPeripheral (DD)

- (void)setFoundRSSI:(NSNumber *)foundRSSI {
    objc_setAssociatedObject(self, @selector(foundRSSI), foundRSSI, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setServiceUUIDs:(NSArray<CBUUID *> *)serviceUUIDs {
    objc_setAssociatedObject(self, @selector(serviceUUIDs), serviceUUIDs, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setLocalName:(NSString *)localName {
    objc_setAssociatedObject(self, @selector(localName), localName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setCharacteristicRead:(CBCharacteristic *)characteristicRead {
    objc_setAssociatedObject(self, @selector(characteristicRead), characteristicRead, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCharacteristicWrite:(CBCharacteristic *)characteristicWrite {
    objc_setAssociatedObject(self, @selector(characteristicWrite), characteristicWrite, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCharacteristicIndication:(CBCharacteristic *)characteristicIndication {
    objc_setAssociatedObject(self, @selector(characteristicIndication), characteristicIndication, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)foundRSSI {
    return objc_getAssociatedObject(self, @selector(foundRSSI));
}

- (NSArray<CBUUID *> *)serviceUUIDs {
    return objc_getAssociatedObject(self, @selector(serviceUUIDs));
}

- (NSString *)localName {
    return objc_getAssociatedObject(self, @selector(localName));
}

- (CBCharacteristic *)characteristicRead {
    return objc_getAssociatedObject(self, @selector(characteristicRead));
}

- (CBCharacteristic *)characteristicWrite {
    return objc_getAssociatedObject(self, @selector(characteristicWrite));
}

- (CBCharacteristic *)characteristicIndication {
    return objc_getAssociatedObject(self, @selector(characteristicIndication));
}

- (void) clearCharacteristics {
    self.characteristicRead = nil;
    self.characteristicWrite = nil;
    self.characteristicIndication = nil;
}

@end