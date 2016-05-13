//
//  DDConnectAgent.h
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
 `DDConnectAgentStatus` enum values are to branch timeout callback type based on if it's connecting, or discovering.
 */
typedef NS_ENUM(NSUInteger, DDConnectAgentStatus) {
    DDConnectAgentStatusDefault,
    DDConnectAgentStatusConnecting,
    DDConnectAgentStatusDiscovering,
};

/**
 `DDConnectAgent` performs tasks of Connect, Disconnect, and Discovery of characteristics.
 `DDConnectAgent` wraps some methods of `DDCentralManager` in order to offer more practical and useful methods.
 */
@interface DDConnectAgent : NSObject <CBPeripheralDelegate> 

/**
 Value that represents total counts of reconnection trials.
 */
@property (nonatomic) int connectionTrialCount;

/**
 Value that represents max counts of reconnection trial, if `connectionTrialCount` exceeds this value, reconnection trial wouldn't be made and error returns to callback block.
 */
@property (nonatomic) int maxConnectionTrialCount;

/**
 Value that represents the time spent to establish the connection.
 */
@property (nonatomic) NSTimeInterval connectionTrialElapsedTime;

/**
 Start connecting to a peripheral. 
 If unexpected disconnection occurs within an interval specified, automatic reconnection trial would be performed until the reconnection trial count reaches max counts specified.
 This method is used as a default method of connecting to a peripheral due to iOS `BTServer` bug.
 
 @see https://devzone.nordicsemi.com/question/45080/difficulties-during-unpairing-process-using-an-iphone/
 
 @param peripheral A `CBPeripheral` object connecting to. Must not be `nil`.
 @param maxRetryCount Max counts that limits the number of reconnection trial. Must not be `nil`.
 @param intervalSeconds If unexpected disconnection happens within specified `intervalSeconds` after connection established, reconnectoin trial would be performed automatically.
 @param completion `Block` object that will be executed when connection established, unexpected disconnection occurs, or timeout.
 */
- (void)startConnectionWithRetry:(CBPeripheral *)peripheral withMaxRetryCount:(int)maxRetryCount interval:(NSTimeInterval)intervalSeconds didConnect:(DDCentralBlockConnectionStatus)completion;

/**
 Start discovering characteristics of a peripheral.
 
 @param peripheral A `CBPeripheral` object connecting to. Must not be `nil`.
 @param completion `Block` object that will be executed when characteristic discovered, or timeout.
 */
- (void)discover:(CBPeripheral *)peripheral didDiscover:(DDCentralBlockDidDiscoverCharacteristics)completion;

/**
 Start disconnecting from a currently connected peripheral.
 
 @param completion `Block` object that will be executed when disconnected from a peripheral, or timeout.
 */
- (void)disconnect:(DDCentralBlockConnectionStatus)completion;

@end
