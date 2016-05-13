//
//  DDCentralManager.m
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

#import "DDCentralManager.h"
#import "CBPeripheral+DD.h"
#import "DDPeripheralConstant.h"

@interface DDCentralManager ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *targetPeripheral;
@property (nonatomic, copy) DDCentralBlockDidUpdateCentralState didUpdateCentralStateBlock;
@property (nonatomic, copy) DDCentralBlockDidDiscoverPeripheral didDiscoverPeripheralBlock;
@property (nonatomic, copy) DDCentralBlockConnectionStatus connectionStatusBlock;

@end

@implementation DDCentralManager

static DDCentralManager *sharedManager_ = nil;

+ (DDCentralManager *)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager_ = [DDCentralManager new];
    });
    return sharedManager_;
}

/**
 In order to prevent this singleton instance from being allocated by other instance,
 override allocWithZone to make it sure it only returns self once
 */
+ (id)allocWithZone:(struct _NSZone *)zone {
    __block id ret = nil;
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedManager_ = [super allocWithZone:zone];
        ret = sharedManager_;
    });
    
    return  ret;
}

/**
 Override copyWithZone to make is sure that copied instance still returns self
 */
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)initialize:(dispatch_queue_t)queue options:(NSDictionary *)options didInitialize:(DDCentralBlockDidUpdateCentralState)completion {
    self.didUpdateCentralStateBlock = completion;
    self.connectionStatus = ConnectionStatusUnknown;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
}

/**
 Make shared instace nil for re-allocation after deallocation
 */
- (void)terminate {
    sharedManager_ = nil;
}

- (id)init {
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)startScan:(NSArray *)serviceUUID didDiscoverPeripheral:(DDCentralBlockDidDiscoverPeripheral)completion {
    self.didDiscoverPeripheralBlock = completion;
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centralManager scanForPeripheralsWithServices:serviceUUID options:options];
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)connect:(CBPeripheral *)peripheral didConnect:(DDCentralBlockConnectionStatus)completion {
    if (peripheral)
    {
        self.targetPeripheral = peripheral;
        self.connectionStatusBlock = completion;
        [self.centralManager connectPeripheral:self.targetPeripheral options:nil];
    }
}

- (void)disconnect:(CBPeripheral *)peripheral didDisconnect:(DDCentralBlockConnectionStatus)completion {
    if (peripheral)
    {
        self.targetPeripheral = peripheral;
        self.connectionStatusBlock = completion;
        [self.centralManager cancelPeripheralConnection:self.targetPeripheral];
    }
}

- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers {
    NSArray *result = [self.centralManager retrievePeripheralsWithIdentifiers:identifiers];
    return result;
}

#pragma mark - CBCentralManagerDelegate Protocol methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.didUpdateCentralStateBlock(central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    peripheral.foundRSSI = RSSI;
    peripheral.serviceUUIDs = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    peripheral.localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    self.didDiscoverPeripheralBlock(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    self.targetPeripheral = peripheral;
    self.connectionStatus = ConnectionStatusConnected;
    self.connectionStatusBlock(self.targetPeripheral, self.connectionStatus, nil);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    self.targetPeripheral = nil;
    self.connectionStatus = ConnectionStatusDisconnected;
    self.connectionStatusBlock(peripheral, self.connectionStatus, error);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"didFailToConnectPeripheral error: %@", error);
}

@end
