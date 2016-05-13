//
//  DDScannedPeripherals.h
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

#import <UIKit/UIKit.h>
@class CBPeripheral;

/**
 `DDScannedPeripherals` is Singleton class that stores peripherals found by one scan.
 
 @warning At the begining of scan, all stored peripherals are removed. Please refer to `startScanForServices` method in `DDScanAgent` class.
 */
@interface DDScannedPeripherals : NSObject

/**
 Returns Singleton object of `DDScannedPeripherals`
 
 @return `DDScannedPeripherals` instance.
 */
+ (DDScannedPeripherals *)sharedPeripherals;

/**
 Initialize `DDScannedPeripherals` instance
 */
- (void)initialize;

/**
 Add peripherals to found peripherals array.
 
 @param peripheral `CBPeripheral` object that is to be added.
 */
- (void)addPeripheral:(CBPeripheral *)peripheral;

/**
 Remove all stored peripherals
 */
- (void)clear;

/**
 Check if the same peripheral alrady exists in stored peripherals array.
 
 @param peripheral `CBPeripheral` object to be checked if alreay exists in stored peripherals array.
 
 @return YES if exist, otherwise NO.
 */
- (BOOL)isExist:(CBPeripheral *)peripheral;

/**
 Returns an array of stored peripherals.
 
 @return `NSArray` object of `CBPeripheral` sorted by found RSSI values in descending order.
 */
- (NSArray *)getRssiSortedPeripherals;

/**
 Returns count of stored peripherals array.
 
 @return `NSUInteger` object that represents the count of stored peripherals array.
 */
- (NSUInteger)count;

@end
