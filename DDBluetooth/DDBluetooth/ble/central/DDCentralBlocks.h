//
//  DDCentralBlocks.h
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 `DDCentralBlocks` is a class that defines blocks handled by classes that peform Bluetooth
 central tasks in DDBluetooth library.
 */

/**
 `ConnectionStatus` enum values represent connection state of central.
 */
typedef NS_ENUM(NSUInteger, ConnectionStatus) {
    ConnectionStatusUnknown = 0,
    ConnectionStatusConnected,
    ConnectionStatusDisconnected,
};

/**
 Returns `CBCentralManagerStateblock` when it's changed.
 Invokes in `initialize` method of `DDCentralManager` class.
 */
typedef void (^DDCentralBlockDidUpdateCentralState)(CBCentralManagerState state);

/**
 Returns `CBPeripheral` when it's found by scan.
 Invokes in `startScan` method of `DDScanAgent` class.
 */
typedef void (^DDCentralBlockDidDiscoverPeripheral)(CBPeripheral * __nonnull peripheral);

/**
 Returns `void` when scan stops.
 Invokes in `startScan` method of `DDScanAgent` class.
 */
typedef void (^DDCentralBlockDidStopScan)();

/**
 Returns `CBPeripheral`, `ConnectionStatus` and `NSError` when success or fail to connect, or disconnect.
 Invokes in `startConnectionWithRetry` and `disconnect` method of `DDConnectAgent` class.
 */
typedef void (^DDCentralBlockConnectionStatus)(CBPeripheral* __nullable peripheral, ConnectionStatus status, NSError * __nullable error);

/**
 Returns `NSArray of CBCharacteristics` and `NSError` success or fail to discover characteristics.
 Invokes in `discover` method of `DDConnectAgent` class.
 */
typedef void (^DDCentralBlockDidDiscoverCharacteristics)(NSArray * __nullable characteristics, NSError *__nullable error);

