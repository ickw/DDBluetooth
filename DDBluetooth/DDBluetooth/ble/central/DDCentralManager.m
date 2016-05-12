
//
//  DDCentralManager.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

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
