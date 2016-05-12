//
//  DDScannedPeripherals.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/30.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "DDScannedPeripherals.h"
#import "NSMutableArray+KeySort.h"
#import "CBPeripheral+DD.h"

static DDScannedPeripherals *sharedPeripherals_;

@interface DDScannedPeripherals()

@property (atomic, strong) NSMutableArray *peripherals;

@end

@implementation DDScannedPeripherals

+ (DDScannedPeripherals *)sharedPeripherals {
    if (!sharedPeripherals_)
    {
        sharedPeripherals_ = [DDScannedPeripherals new];
    }
    return sharedPeripherals_;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    __block id ret = nil;
    static dispatch_once_t once;
    
    dispatch_once( &once, ^{
        sharedPeripherals_ = [super allocWithZone:zone];
        ret = sharedPeripherals_;
    });
    return  ret;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)initialize {
    if (!self.peripherals) self.peripherals = [[NSMutableArray alloc] init];
}

- (void)addPeripheral:(CBPeripheral*)peripheral {
    [self.peripherals addObject:peripheral];
}

- (void)clear {
    if ([self.peripherals count]) [self.peripherals removeAllObjects];
}

- (BOOL)isExist:(CBPeripheral *)peripheral {
    return [self.peripherals containsObject:peripheral];
}

- (NSArray *)getRssiSortedPeripherals {
    NSArray *result = [self.peripherals copy];
    result = [self.peripherals sortByKey:@"foundRSSI" ascending:NO];
    return result;
}

- (NSUInteger )count {
    return [self.peripherals count];
}

@end
