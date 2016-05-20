//
//  DDCentralManager.h
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
#import "DDCentralBlocks.h"

/**
 `DDCentralManager` wraps `CBCentralManager` to add it callback blocks functionality.
 `DDCentralManager` has low-level methods utilised by `DDScanAgent` and `DDConnectAgent`, so apart from `initialize` method,
 one should access those methods via `DDScanAgent` or `DDConnectAgent`.
 */
@interface DDCentralManager : NSObject <CBCentralManagerDelegate>

/**
 Connection status of bluetooth central
 */
@property (nonatomic, assign) ConnectionStatus connectionStatus;

/**
 Returns Singleton object of `DDCentralManager`
 
 @return `DDCentralManager` instance
 */
+ (DDCentralManager *)sharedManager;


/**
 Initialize `CBCentralManager` and check if bluetooth is available on the device.
 
 @param queue A queue to perform Bluetooth task. If `nil` is given, main queue will be applied.
 @param options `NSDictionary` object of `CBCentralManagerOption` keys. If nil is given, no keys are applied.
 @param completion `Block` object that will be executed when `DDCentralBlockDidUpdateCentralState` invokes.
 */
- (void)initialize:(dispatch_queue_t)queue options:(NSDictionary *)options didInitialize:(DDCentralBlockDidUpdateCentralState)completion;

/**
 Release Singleton object of `DDCentralManager` created by `Initialize` method. This method must be called when one needs to recreate Singleton object again.
 */
- (void)terminate;

/**
 Start scan.
 
 @param serviceUUID `NSArray` object of `CBUUID`. If `nil` is given, it scans for any service UUIDs.
 @param completion `Block` object that will be executed when peripheral is found.
 */
- (void)startScan:(NSArray *)serviceUUID didDiscoverPeripheral:(DDCentralBlockDidDiscoverPeripheral)completion;

/**
 Stop scan.
 */
- (void)stopScan;

/**
 Connect to a peripheral.
 
 @param peripheral `CBPeripheral` object that one want to connect to. Must not be `nil`.
 @param completion `Block object that will be executed when connection with peripheral established, or disconnected unexpectedly.
 */
- (void)connect:(CBPeripheral *)peripheral didConnect:(DDCentralBlockConnectionStatus)completion;

/**
 Disconnect from a peripheral.
 
 @param peripheral `CBPeripheral` object that one want to disconnect from. Must not be `nil`.
 @param completion `Block` object that will be executed when disconnection from the peripheral is accomplished.
 */
- (void)disconnect:(CBPeripheral *)peripheral didDisconnect:(DDCentralBlockConnectionStatus)completion;

/**
 Get array of peripherals that are cached in iDevice
 
 @param identifiers NSArray object of peripherl identifiers
 
 @return NSArray object of found CBPripheral objects
 */
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;

/**
 Remove a cached peripheral
 @param UUID UUID (identifier) of peripheral
 */
- (void)removeStoredPeripheralWithUUID:(NSUUID *)UUID;

@end
