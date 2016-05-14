//
//  DDTransactionCellModel.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/09.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDTransactionCellModel.h"

@implementation DDTransactionCellModel

- (id)initWithEnabled:(BOOL)enabled {
    self = [super init];
    if (self)
    {
        [self reset:enabled];
    }
    return self;
}

- (void)reset:(BOOL)enabled {
    self.enabled = enabled;
    self.isWriteWithResponse = YES;
    self.indicationStatus = IndicationStatusDefault;
    self.readStatus = ReadStatusDefault;
    self.writeStatus = WriteStatusDefault;
    self.notifiedValue = @"";
    self.readValue = @"";
}

@end
