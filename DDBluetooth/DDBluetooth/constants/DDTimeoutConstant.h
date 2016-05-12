//
//  DDTimeoutConstant.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/04.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTimeoutConstant : NSObject

extern NSTimeInterval const kTimeoutIntervalScan;
extern NSTimeInterval const kTimeoutIntervalConnect;
extern NSTimeInterval const kTimeoutIntervalDisconnect;
extern NSTimeInterval const kTimeoutIntervalDiscoverCharacteristic;
extern NSTimeInterval const kTimeoutIntervalTransaction;
extern NSTimeInterval const kIntervalReconnect;

@end
