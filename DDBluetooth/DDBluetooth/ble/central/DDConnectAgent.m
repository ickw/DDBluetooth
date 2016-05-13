//
//  DDConnectAgent.m
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

#import "DDConnectAgent.h"
#import "DDCentralManager.h"
#import "DDPeripheralConstant.h"
#import "CBPeripheral+DD.h"
#import "DDErrorUtil.h"
#import "DDTimeoutConstant.h"

@interface DDConnectAgent ()

@property (nonatomic, strong) CBPeripheral* targetPeripheral;
@property (nonatomic, strong) NSMutableArray *characteristicList;
@property (nonatomic, copy) DDCentralBlockDidDiscoverCharacteristics didDiscoverCharacteristicBlock;
@property (nonatomic, copy) DDCentralBlockConnectionStatus connectionStatusBlock;
@property (nonatomic) DDConnectAgentStatus ddConnectAgentStatus;
@property (nonatomic) BOOL isTimeout;
@property (nonatomic) BOOL isConnectionCheckValid;
@property (nonatomic) NSTimer *watchdogTimer;
@property (nonatomic) NSTimer *connectionTrialTimer;
@property (nonatomic) NSTimeInterval connectionTrialInterval;
@property (nonatomic) NSDate *connectionStartTime;

@end

@implementation DDConnectAgent

- (id)init {
    self = [super init];
    if (self)
    {
        if (!self.characteristicList) self.characteristicList = [[NSMutableArray alloc] init];
        self.isTimeout = NO;
        self.ddConnectAgentStatus = DDConnectAgentStatusDefault;
        self.maxConnectionTrialCount = 0;
        self.connectionTrialCount = 0;
        self.isConnectionCheckValid = NO;
    }
    return self;
}

- (void)invalidateWatchdog {
    [self.watchdogTimer invalidate];
}

- (void)startConnectionWithRetry:(CBPeripheral *)peripheral withMaxRetryCount:(int)maxRetryCount interval:(NSTimeInterval)intervalSeconds didConnect:(DDCentralBlockConnectionStatus)completion {
    if (!peripheral) return;
    
    self.ddConnectAgentStatus = DDConnectAgentStatusConnecting;
    self.targetPeripheral = peripheral;
    self.targetPeripheral .delegate = self;
    self.connectionStatusBlock = completion;
    

    self.maxConnectionTrialCount = maxRetryCount;
    self.connectionTrialCount = 0;
    self.connectionTrialInterval = intervalSeconds;
    self.connectionStartTime = [NSDate date];
    self.connectionTrialElapsedTime = 0.f;
    self.isConnectionCheckValid = YES;
    self.isTimeout = NO;
    
    
    __weak typeof(self) weakSelf = self;
    void (^__block __weak weakConnectRecurse)();
    void (^__block __strong connectRecurse)();
    
    weakConnectRecurse = connectRecurse = ^(){
        
        // Perform starting watchdog in main thread to make it sure that NSTimer method fires
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf startWatchdog:kTimeoutIntervalConnect];
        });
        
        // perform retryConnect if not timed out
        if (weakSelf.connectionTrialCount < weakSelf.maxConnectionTrialCount)
        {
            // make a strong reference from the captured weak reference inside the block
            void(__block ^innerConnect)() = weakConnectRecurse;
            
            [[DDCentralManager sharedManager] connect:peripheral didConnect:^(CBPeripheral *peripheral, ConnectionStatus status, NSError *error) {
                
                // make a strong reference from the captured weak reference inside the block
                typeof(self) innerSelf = weakSelf;
                
                if (status == ConnectionStatusDisconnected)
                {
                    innerSelf.connectionStatusBlock(peripheral, status, error);
                    if (innerSelf.isConnectionCheckValid) innerConnect();
                    
                    // increment retry count
                    weakSelf.connectionTrialCount++;
                }
                else if (status == ConnectionStatusConnected)
                {
                    if (weakSelf.isTimeout)
                    {
                        // if it's already time out, not call a block & disconnect;
                        [innerSelf disconnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {
                        }];
                        return;
                    }
                    
                    // Perform NStTimer related methods in main thread to make it sure that NSTimer method fires
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [innerSelf invalidateWatchdog];
                        [innerSelf startConnectionCheckTimer];
                    });
                    
                    [innerSelf calcConnectionTrialElapsedTime];
                    innerSelf.connectionStatusBlock(peripheral, status, error);
                }
                else
                {
                    innerSelf.connectionStatusBlock(peripheral, status, error);
                }
            }];
        }
        else
        {
            NSError *error = [DDErrorUtil errorWithCode:kDDBluetoothErrorCodeMaxRetryCount description:@"reached to max retry count" suggetion:@"please start from scan again"];
            weakSelf.connectionStatusBlock(peripheral, ConnectionStatusDisconnected, error);
            
            return;
        }
    };
    
    
    /*
     * recursive connecting trial could impact on peformance, so do it in global queue
     */
    dispatch_queue_t global_default_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_default_queue, ^{
        connectRecurse();
    });
}

- (void)startConnectionCheckTimer {
    self.isConnectionCheckValid = YES;
    if(self.connectionTrialTimer.valid) [self.connectionTrialTimer invalidate];
    self.connectionTrialTimer = [NSTimer scheduledTimerWithTimeInterval:self.connectionTrialInterval
                                                                 target:self
                                                               selector:@selector(cancelConnectionCheck)
                                                               userInfo:nil
                                                                repeats:NO];
}

- (void)cancelConnectionCheck{
    [_connectionTrialTimer invalidate];
    self.isConnectionCheckValid = NO;
}

- (void)calcConnectionTrialElapsedTime {
    NSDate *reconnectedTime = [NSDate date];
    _connectionTrialElapsedTime = [reconnectedTime timeIntervalSinceDate:_connectionStartTime];
}

- (void)disconnect:(DDCentralBlockConnectionStatus)completion {
    if (self.targetPeripheral == nil) return;
    
    self.connectionStatusBlock = completion;
    
    // TODO: Review if disconnection needs watchdog
    [self startWatchdog:kTimeoutIntervalDisconnect];
    
    __weak __typeof (self) weakSelf = self;
    [[DDCentralManager sharedManager] disconnect:self.targetPeripheral didDisconnect:^(CBPeripheral *peripheral, ConnectionStatus status, NSError * error) {
        
        if (status == ConnectionStatusDisconnected)
        {
            [weakSelf invalidateWatchdog];
            
            self.targetPeripheral.delegate = nil;
            self.targetPeripheral = nil;
        }
    
        self.connectionStatusBlock(peripheral, status, error);
    }];
}

- (void)discover:(CBPeripheral *)peripheral didDiscover:(DDCentralBlockDidDiscoverCharacteristics)completion {
    if (peripheral == nil) return;
    
    if ([self.characteristicList count]) [self.characteristicList removeAllObjects];
    self.ddConnectAgentStatus = DDConnectAgentStatusDiscovering;
    self.didDiscoverCharacteristicBlock = completion;
    
    self.targetPeripheral = peripheral;
    self.targetPeripheral.delegate = self;
    //[self.targetPeripheral clearCharacteristics];
    [self.targetPeripheral discoverServices:self.targetPeripheral.serviceUUIDs];
    
    [self startWatchdog:kTimeoutIntervalDiscoverCharacteristic];
}

- (void)startWatchdog:(NSTimeInterval)interval {
    if (self.watchdogTimer.valid) [self.watchdogTimer invalidate];
    self.isTimeout = NO;
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(timeout:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)timeout:(NSTimer *)aTimer {
    self.isTimeout = YES;
    [self.watchdogTimer invalidate];
    [self cancelConnectionCheck];
    
    NSError *error = [DDErrorUtil errorWithCode:kDDBluetoothErrorCodeTimeout description:@"timeout" suggetion:@"please retry again"];
        
    if (self.ddConnectAgentStatus == DDConnectAgentStatusConnecting)
    {
        ConnectionStatus status = [DDCentralManager sharedManager].connectionStatus;
        self.connectionStatusBlock(nil, status, error);
    }
    else if (self.ddConnectAgentStatus == DDConnectAgentStatusDiscovering)
    {
        self.didDiscoverCharacteristicBlock(nil, error);
    }
    
    self.ddConnectAgentStatus = DDConnectAgentStatusDefault;
}


#pragma mark -CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (self.isTimeout) return;
    
    if (error)
    {
        [self.watchdogTimer invalidate];
        self.didDiscoverCharacteristicBlock(nil, error);
        return;
    }
    else
    {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (self.isTimeout) return;
    
    [self.watchdogTimer invalidate];
    
    if (error)
    {
        self.didDiscoverCharacteristicBlock(nil, error);
        return;
    }
    else
    {
        for (CBCharacteristic *characteristic in service.characteristics) {

            [self.characteristicList addObject:characteristic];
        }
  
        self.didDiscoverCharacteristicBlock(self.characteristicList, nil);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    NSLog(@"didModifyServices %@", invalidatedServices);
    
    // Rediscover services
    [self discover:peripheral didDiscover:^(NSArray * _Nullable characteristics, NSError * _Nullable error) {
        NSLog(@"rediscovered characteristics %@", characteristics);
    }];
}

@end
