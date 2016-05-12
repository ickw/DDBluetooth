//
//  DDPeripheralConstant.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/28.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DDPeripheralConstant : NSObject

extern NSString * const DD_ERROR_DOMAIN;
extern int const DD_ERROR_CODE;

extern NSUInteger const DD_WRITE_PAYLOAD_LENGTH;
extern int const DD_MAX_RECONNECTION_COUNT;

@end
