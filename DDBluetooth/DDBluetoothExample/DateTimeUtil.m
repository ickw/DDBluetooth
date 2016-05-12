//
//  DateTimeUtil.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/04.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "DateTimeUtil.h"

@implementation DateTimeUtil

+ (NSString *)getTimeStamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getTimeStampInMillis {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
    return [dateFormatter stringFromDate:[NSDate date]];
}


@end
