//
//  DDScanAgent.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "DDScanAgent.h"
#import "DDCentralManager.h"
#import "DDPeripheralConstant.h"
#import "DDScannedPeripherals.h"
#import "DDTimeoutConstant.h"
#import "CBPeripheral+DD.h"

@interface DDScanAgent ()

@property (nonatomic, copy) DDCentralBlockDidStopScan didStopScanBlock;
@property (nonatomic) NSTimer *watchdogTimer;

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
    
    [self startWatchdog:interval];
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