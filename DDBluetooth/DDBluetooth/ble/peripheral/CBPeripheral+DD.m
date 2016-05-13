//
//  CBPeripheral+DD.m
//  DDBluetooth
//
// Copyright (c) 2015–2016 Daiki Ichikawa ( https://github.com/ickw )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

/*
- (void)setCharacteristicRead:(CBCharacteristic *)characteristicRead {
    objc_setAssociatedObject(self, @selector(characteristicRead), characteristicRead, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCharacteristicWrite:(CBCharacteristic *)characteristicWrite {
    objc_setAssociatedObject(self, @selector(characteristicWrite), characteristicWrite, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCharacteristicIndication:(CBCharacteristic *)characteristicIndication {
    objc_setAssociatedObject(self, @selector(characteristicIndication), characteristicIndication, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
 */

- (NSNumber *)foundRSSI {
    return objc_getAssociatedObject(self, @selector(foundRSSI));
}

- (NSArray<CBUUID *> *)serviceUUIDs {
    return objc_getAssociatedObject(self, @selector(serviceUUIDs));
}

- (NSString *)localName {
    return objc_getAssociatedObject(self, @selector(localName));
}

/*
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
 */

@end