//
//  DDStoredPeripheralse.m
//  DDBluetooth
//
// Copyright (c) 2015–2016 Daiki Ichikawa ( https://github.com/ickw )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
