//
//  DDTransactionAgent.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/27.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSUInteger, DDTransactionAgentCallbackType) {
    DDTransactionAgentCallbackTypeUnknown = 0,
    DDTransactionAgentCallbackTypeIndication,
    DDTransactionAgentCallbackTypeNotifiedValue,
    DDTransactionAgentCallbackTypeReadValue,
    DDTransactionAgentCallbackTypeWriteValue
};

typedef void (^DDTransactionAgentBlock)(DDTransactionAgentCallbackType type, NSData *data, NSError *error);

/**
    Since notification event could happen anytime during app session,
    it's better to handle it by delegate rather than block in some cases.
 */
@protocol  DDTransactionAgentDelegate

@optional
- (void)didNotifiedValue:(CBCharacteristic *)characteristic value:(NSData *)value error:(NSError *)error;

@end

@interface DDTransactionAgent : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *mPeripheral;
@property (nonatomic, weak) id<DDTransactionAgentDelegate> delegate;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)read:(CBCharacteristic *)characteristic didRead:(DDTransactionAgentBlock)completion;

- (void)write:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse;

- (void)writeSplit:(CBCharacteristic *)characteristic data:(NSData *)data withResponse:(BOOL)withResponse didWrite:(DDTransactionAgentBlock)completion;

- (void)indicate:(CBCharacteristic *)characteristic didIndicate:(DDTransactionAgentBlock)completion;

- (void)invalidateTimer;

@end
