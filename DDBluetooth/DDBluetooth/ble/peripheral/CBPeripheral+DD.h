//
//  CBPeripheral+DD.h
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

#import <CoreBluetooth/CoreBluetooth.h>

/**
 Category class of `CBPeripheral`.
 One may customise this class (i.e. Adding characteristics of the peripheral device one is developing) for more efficient and specific usage of DDBluetooth library.
 */
@interface CBPeripheral (DD)

/**
 Value of peripheral's RSSI when it's found.
 */
@property (nonatomic, strong) NSNumber *foundRSSI;

/**
 Peripheral's serviceUUIDs as `NSArray`
 */
@property (nonatomic, copy) NSArray<CBUUID *> *serviceUUIDs;

/**
 Local name of advertising packet.
 */
@property (nonatomic, copy) NSString *localName;


/*
@property (nonatomic, strong) CBCharacteristic *characteristicIndication;
@property (nonatomic, strong) CBCharacteristic *characteristicWrite;
@property (nonatomic, strong) CBCharacteristic *characteristicRead;
- (void)clearCharacteristics;
 */

@end
