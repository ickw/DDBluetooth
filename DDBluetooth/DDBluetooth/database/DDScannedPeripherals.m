//
//  DDScannedPeripherals.m
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
