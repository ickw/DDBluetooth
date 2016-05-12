//
//  NSData+Conversion.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/25.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "NSData+Conversion.h"

@implementation NSData (Conversion)

- (NSString *)hexString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger dataLength = [self length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i=0; i < dataLength; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}


@end
