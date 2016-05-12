//
//  DDErrorUtil.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/04.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "DDErrorUtil.h"

@implementation DDErrorUtil

static NSString * const kDDBluetoothErrorDomain = @"com.ddbluetooth.error.domain";

+ (NSError *)errorWithCode:(kDDBluetoothErrorCode)errorCode description:(NSString *)description suggetion:(NSString *)suggestion {
    NSDictionary *errorDic = @ {
        NSLocalizedDescriptionKey:@"timeout",
        NSLocalizedRecoverySuggestionErrorKey:@"please try again"
    };;
    
    NSError *error = [[NSError alloc] initWithDomain:kDDBluetoothErrorDomain code:errorCode userInfo:errorDic];
    
    return  error;
}

@end
