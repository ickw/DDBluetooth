//
//  DDStoredPeripheralse.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/02/25.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDStoredPeripherals.h"

@implementation DDStoredPeripherals

static NSString *key = @"storedPeripherals";

+ (void)initialize {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *identifiers = [userDefaults arrayForKey:key];
    if (!identifiers)
    {
        [userDefaults setObject:@[] forKey:key];
        [userDefaults synchronize];
    }
}

+ (NSArray *)getIdentifiers {
    NSMutableArray *result = [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *identifiers = [userDefaults arrayForKey:key];
    
    for (id uuidString in identifiers) {
        if (![uuidString isKindOfClass:[NSString class]]) continue;
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        if (!uuid) continue;
    
        [result addObject:uuid];
    }
    
    return result;
}

+ (void)saveUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *existingIdentifiers = [userDefaults objectForKey:key];
    NSMutableArray *identifiers;
    NSString *uuidString = nil;
    
    if (UUID)
    {
        uuidString = UUID.UUIDString;
        
        if (existingIdentifiers)
        {
            identifiers = [[NSMutableArray alloc] initWithArray:existingIdentifiers];
            
            if (uuidString)
            {
                for (NSString *identifier in existingIdentifiers) {
                    if ([identifier isEqualToString:uuidString]) break;
                }
                
                [identifiers addObject:uuidString];
            }
        }
        else
        {
            identifiers = [[NSMutableArray alloc] init];
            [identifiers addObject:uuidString];
        }
        
        [userDefaults setObject:identifiers forKey:key];
        [userDefaults synchronize];
    }
}

+ (void)deleteUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *identifiers = [userDefaults arrayForKey:key];
    NSMutableArray *newIdentifiers = [NSMutableArray arrayWithArray:identifiers];
    
    NSString *uuidString = UUID.UUIDString;
    [newIdentifiers removeObject:uuidString];
    
    [userDefaults setObject:newIdentifiers forKey:key];
    [userDefaults synchronize];
}

@end
