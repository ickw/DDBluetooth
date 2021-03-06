//
//  DDTransactionAgent.m
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

#import "DDTransactionAgent.h"
#import "NSData+Conversion.h"
#import "DDTimeoutConstant.h"
#import "DDPeripheralConstant.h"
#import "NSData+Conversion.h"

typedef NS_ENUM(NSUInteger, DDTransactionAgentState) {
    DDTransactionAgentStateDefault = 0,
    DDTransactionAgentStateReading,
    DDTransactionAgentStateWriting,
};

@interface DDTransactionAgent()

@property (nonatomic, strong) DDTransactionAgentBlock transactionBlock;
@property (nonatomic, strong) NSTimer * watchdogTimer;
@property (nonatomic) BOOL isTimeout;
@property (nonatomic) DDTransactionAgentState currrentState;

@end

@implementation DDTransactionAgent

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self)
    {
        self.mPeripheral = peripheral;
        self.mPeripheral.delegate = self;
        self.currrentState = DDTransactionAgentStateDefault;
    }
    return self;
}

- (void)read:(CBCharacteristic *)characteristic didRead:(DDTransactionAgentBlock)completion {
    if (characteristic)
    {
        self.transactionBlock = completion;
        self.currrentState = DDTransactionAgentStateReading;
        
        if (self.mPeripheral.delegate != self) self.mPeripheral.delegate = self;
        [self.mPeripheral readValueForCharacteristic:characteristic];
        
        [self startWatchdog];
    }
}

/*
- (void)write:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse {
    
    if (!data) return;
    
    if (characteristic)
    {
        // Set write type
        CBCharacteristicWriteType type;
        if (withResponse) type = CBCharacteristicWriteWithResponse;
        else type = CBCharacteristicWriteWithoutResponse;
        
        //
        if (self.mPeripheral.delegate != self) self.mPeripheral.delegate = self;
        [self.mPeripheral writeValue:data forCharacteristic:characteristic type:type];
        
        // validate watchdog only when "WriteWithResponse"
        if (type == CBCharacteristicWriteWithResponse) [self startWatchdog];
    }
}
 */

- (void)writeSplit:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse didWrite:(DDTransactionAgentBlock)completion {
    
    if (!data) return;
    if (!characteristic) return;

    // Set write type
    CBCharacteristicWriteType type;
    if (withResponse) type = CBCharacteristicWriteWithResponse;
    else type = CBCharacteristicWriteWithoutResponse;
    
    //
    if (self.mPeripheral.delegate != self) self.mPeripheral.delegate = self;
    self.transactionBlock = completion;
    
    //
    NSMutableArray *DividedDataArray = [NSMutableArray array];
    if (data.length > DD_WRITE_PAYLOAD_LENGTH)
    {
        //
        NSUInteger divisionNumber = data.length / DD_WRITE_PAYLOAD_LENGTH;
        NSUInteger mod = data.length % DD_WRITE_PAYLOAD_LENGTH;
        
        for (int i=0; i<=divisionNumber; i++) {
            if (i < divisionNumber)
            {
                NSUInteger startIndex = i * DD_WRITE_PAYLOAD_LENGTH;
                NSData *dividedData = [data subdataWithRange:NSMakeRange(startIndex, DD_WRITE_PAYLOAD_LENGTH)];
                [DividedDataArray addObject:dividedData];
            }
            else if (mod > 0)
            {
                NSUInteger startIndex = divisionNumber * DD_WRITE_PAYLOAD_LENGTH;
                NSData *dividedData = [data subdataWithRange:NSMakeRange(startIndex, mod)];
                [DividedDataArray addObject:dividedData];
            }
        }
        
        for (int i=0; i<DividedDataArray.count; i++) {
            if (i > 0) [NSThread sleepForTimeInterval:0.1];
            
            NSData *dividedData = [DividedDataArray objectAtIndex:i];
            [self.mPeripheral writeValue:dividedData forCharacteristic:characteristic type:type];
        }
    }
    else
    {
        // No need to split the data
        [self.mPeripheral writeValue:data forCharacteristic:characteristic type:type];
    }
    
    // validate watchdog only when "WriteWithResponse"
    if  (type == CBCharacteristicWriteWithResponse) [self startWatchdog];
}

- (void)indicate:(CBCharacteristic *)characteristic didIndicate:(DDTransactionAgentBlock)completion {
    if (characteristic)
    {
        self.transactionBlock = completion;
        
        if (self.mPeripheral.delegate != self) self.mPeripheral.delegate = self;
        [self.mPeripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        [self startWatchdog];
    }
}

- (void)startWatchdog {
    if(self.watchdogTimer.valid) [self.watchdogTimer invalidate];
    self.isTimeout = NO;
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeoutIntervalTransaction target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
}

- (void)timeout:(NSTimer *)timer {
    self.isTimeout = YES;
}

- (void)invalidateTimer {
    [self.watchdogTimer invalidate];
}


#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.isTimeout) return;
    [self.watchdogTimer invalidate];
    
    // didRead value
    if (self.currrentState == DDTransactionAgentStateReading)
    {
        self.currrentState = DDTransactionAgentStateDefault;
        self.transactionBlock(DDTransactionAgentCallbackTypeReadValue, characteristic.value, error);
    }
    // didNotfied value
    else if (self.currrentState == DDTransactionAgentStateDefault)
    {
        self.transactionBlock(DDTransactionAgentCallbackTypeNotifiedValue, characteristic.value, error);
        [self.delegate didReceiveNotification:characteristic value:characteristic.value error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {    
    if (self.isTimeout) return;
    
    self.transactionBlock(DDTransactionAgentCallbackTypeWriteValue, nil, error);
    
    [self.watchdogTimer invalidate];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {    
    if (self.isTimeout) return;
    
    self.transactionBlock(DDTransactionAgentCallbackTypeIndication, nil, error);
    
    [self.watchdogTimer invalidate];
}

@end
