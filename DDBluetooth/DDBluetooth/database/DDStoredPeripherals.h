//
//  DDStoredPeripherals.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/02/25.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDStoredPeripherals : NSObject

+ (void)initialize;

+ (NSArray *)getIdentifiers;

+ (void)saveUUID:(NSUUID *)UUID;

+ (void)deleteUUID:(NSUUID *)UUID;

@end
