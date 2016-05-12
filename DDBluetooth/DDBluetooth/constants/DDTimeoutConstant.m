//
//  DDTimeoutConstant.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/04.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "DDTimeoutConstant.h"

@implementation DDTimeoutConstant

NSTimeInterval const kTimeoutIntervalConnect = 6.0f; // if connection not established in x sec, timeout

NSTimeInterval const kTimeoutIntervalDisconnect = 2.f;

NSTimeInterval const kTimeoutIntervalDiscoverCharacteristic = 6.f;

NSTimeInterval const kTimeoutIntervalTransaction = 6.f;

NSTimeInterval const kIntervalReconnect = 2.f; // if disconnection happens within x sec after connection, try to reconnect

@end
