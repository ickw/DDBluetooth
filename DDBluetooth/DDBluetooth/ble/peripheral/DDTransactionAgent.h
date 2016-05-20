//
//  DDTransactionAgent.h
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
 `DDTransactionAgentCallbackType` is used for one to tell which event has happened;
 
 DDTransactionAgentCallbackTypeUnknown - Unexpected event happens.
 DDTransactionAgentCallbackTypeIndication - Indication is either succeeded, failed, or timed out.
 DDTransactionAgentCallbackTypeNotifiedValue - Notification is either succeeded, failed, or timed out.
 DDTransactionAgentCallbackTypeReadValue - Read is either succeeded, failed, or timed out.
 DDTransactionAgentCallbackTypeWriteValue - Write is either succeeded, failed, or timed out.
 */
typedef NS_ENUM(NSUInteger, DDTransactionAgentCallbackType) {
    DDTransactionAgentCallbackTypeUnknown = 0,
    DDTransactionAgentCallbackTypeIndication,
    DDTransactionAgentCallbackTypeNotifiedValue,
    DDTransactionAgentCallbackTypeReadValue,
    DDTransactionAgentCallbackTypeWriteValue
};

/**
 `DDTransactionAgentBlock` defines Block used in this class
 */
typedef void (^DDTransactionAgentBlock)(DDTransactionAgentCallbackType type, NSData *data, NSError *error);

/**
 A delegate to handle notification from peripheral.
 Although a block is also prepared for notification, notification event could happen anytime during app session so that it can be better to handle it by delegate rather than block in some cases.
 */
@protocol  DDTransactionAgentDelegate

@optional
/**
 Delegate method triggered by notification event.
 
 @param characteristic `CBCharacteristic` object from which notification comes.
 @param value `NSData` object that is notified value.
 @param error `NSError` object comes with notification. Can be `nil`
 */
- (void)didReceiveNotification:(CBCharacteristic *)characteristic value:(NSData *)value error:(NSError *)error;

@end

/**
 `DDTransactionAgent` performs read, write, and indicate operations. It also has both block and delegate methods to handle notificaiton.
 */
@interface DDTransactionAgent : NSObject <CBPeripheralDelegate>

/**
 Peripheral on which read, write, or indication operations performed.
 */
@property (nonatomic, strong) CBPeripheral *mPeripheral;

/**
 Delegate that handles notification event.
 */
@property (nonatomic, weak) id<DDTransactionAgentDelegate> delegate;

/**
 Initialize `DDTransactionAgent`.
 
 @param peripheral `CBPeripheral` object on which read, write, or indication operations performed.
 @return `DDTransactionAgent` object.
 */
- (id)initWithPeripheral:(CBPeripheral *)peripheral;

/**
 Read value of specified characteristic.
 
 @param characteristic `CBCharacteristic` object of which read value.
 @param completion `Block` object that will be executed when succeed or fails to read, or timeout.
 */
- (void)read:(CBCharacteristic *)characteristic didRead:(DDTransactionAgentBlock)completion;


//- (void)write:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse;

/**
 Write value to specified characteristic. Timeout event only fires when `withResponse` param set to YES.
 
 @param characteristic `CBCharacteristic` object to which write value.
 @param data `NSData` object that will be written to characteristic.
 @param withResponse `BOOL` object that set `CBCharacteristicWriteType`. If YES is given, `CBCharacteristicWriteWithResponse` is used, otherwise `CBCharacteristicWriteWithoutResponse` used.
 @param completion `Block` object that will be executed when succeed or fails to write, or timeout (timeout event only fires when `withResponse` param set to YES).
 
 @warning In case `withResponse` set to NO, completion block won't be invoked.
 */
- (void)writeSplit:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse didWrite:(DDTransactionAgentBlock)completion;

/**
 Send indication to a specified characteristic.
 
 @param characteristic `CBCharacteristic` object on which indication performs.
 @param completion `Block` object that will be executed when indication succeeds, fails or timeout.
 */
- (void)indicate:(CBCharacteristic *)characteristic didIndicate:(DDTransactionAgentBlock)completion;

@end
