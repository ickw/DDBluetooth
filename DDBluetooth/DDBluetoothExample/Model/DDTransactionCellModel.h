//
//  DDTransactionCellModel.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/09.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Corebluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, IndicationStatus) {
    IndicationStatusDefault = 0,
    IndicationStatusSuccess,
    IndicationStatusFailed
};

typedef NS_ENUM(NSUInteger, ReadStatus) {
    ReadStatusDefault,
    ReadStatusSuccess,
    ReadStatusFailed
};

typedef NS_ENUM(NSUInteger, WriteStatus) {
    WriteStatusDefault,
    WriteStatusSuccess,
    WriteStatusFailed
};

@interface DDTransactionCellModel : NSObject

@property (nonatomic) BOOL enabled;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic) BOOL isWriteWithResponse;
@property (nonatomic) IndicationStatus indicationStatus;
@property (nonatomic) ReadStatus readStatus;
@property (nonatomic) WriteStatus writeStatus;
@property (nonatomic, copy) NSString *notifiedValue;
@property (nonatomic, copy) NSString *readValue;
@property (nonatomic, copy) NSString *writeValue;

- (id)initWithEnabled:(BOOL)enabled;
- (void)reset:(BOOL)enabled;

@end
