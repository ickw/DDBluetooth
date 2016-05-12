//
//  DDErrorUtil.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/04.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kDDBluetoothErrorCode) {
    kDDBluetoothErrorCodeTimeout = 10001,
    kDDBluetoothErrorCodeMaxRetryCount
};

@interface DDErrorUtil : NSObject

+ (NSError *)errorWithCode:(kDDBluetoothErrorCode)errorCode description:(NSString *)description suggetion:(NSString *)suggestion;

@end
