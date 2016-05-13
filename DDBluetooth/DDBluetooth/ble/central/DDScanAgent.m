//
//  DDScanAgent.m
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

#import "DDScanAgent.h"
#import "DDCentralManager.h"
#import "DDPeripheralConstant.h"
#import "DDScannedPeripherals.h"
#import "DDTimeoutConstant.h"
#import "CBPeripheral+DD.h"

@interface DDScanAgent ()

@property (nonatomic, copy) DDCentralBlockDidStopScan didStopScanBlock;
@property (nonatomic) NSTimer *watchdogTimer;
@property (nonatomic) BOOL isScanning;

@end

@implementation DDScanAgent

- (id)init {
    if (self = [super init])
    {
        self.isScanning = NO;
        [[DDScannedPeripherals sharedPeripherals] initialize];
    }
    return self;
}

- (void)startScanForServices:(NSArray<CBUUID *> *)services withPrefixes:(NSArray<NSString *> *)prefixes interval:(NSTimeInterval)interval found:(void (^)(CBPeripheral *))found stop:(DDCentralBlockDidStopScan)stop {
    if (self.isScanning) return;
  
    self.isScanning = YES;
    self.didStopScanBlock = stop;
    
    // Reset peripheral list
    [[DDScannedPeripherals sharedPeripherals] clear];
    
    [[DDCentralManager sharedManager] startScan:services didDiscoverPeripheral:^(CBPeripheral *peripheral) {
        
        // Skip if the peripheral already exists in the list
        if ([[DDScannedPeripherals sharedPeripherals] isExist:peripheral]) return;
        
        // RSSI = 127 means "RSSI unavailable"
        if (peripheral.foundRSSI == [NSNumber numberWithInteger:127])
        {
            peripheral.foundRSSI = nil;
        }
        
        // Scan for the services with specifix localName prefix?
        if (prefixes)
        {
            [prefixes enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                if ([peripheral.localName hasPrefix:obj]) {
                    
                    [[DDScannedPeripherals sharedPeripherals] addPeripheral:peripheral];
                    found(peripheral);
                }
            }];
        }
        else
        {
            [[DDScannedPeripherals sharedPeripherals] addPeripheral:peripheral];
            found(peripheral);
        }
    }];
    
    if (interval) [self startWatchdog:interval];
    else [self startWatchdog:kTimeoutIntervalScan];
}

- (void)stopScan {
    if (self.isScanning)
    {
        [[DDCentralManager sharedManager] stopScan];
        self.isScanning = NO;
    }
    
    [self cancelWatchdog];
    self.didStopScanBlock();
}

- (void)clear {
    if (self.isScanning)
    {
       [[DDCentralManager sharedManager] stopScan];
        self.isScanning = NO;
    }

    [self.watchdogTimer invalidate];
    [[DDScannedPeripherals sharedPeripherals] clear];
}

- (void)startWatchdog:(NSTimeInterval)interval {
    if (self.watchdogTimer.isValid)
    {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
    }
    
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(stopScan)
                                             userInfo:nil
                                              repeats:NO];
}

- (void)cancelWatchdog {
    if (self.watchdogTimer.isValid)
    {
        [self.watchdogTimer invalidate];
        self.watchdogTimer = nil;
    }
}

@end