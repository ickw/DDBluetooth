//
//  BleTokenDatabase.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/30.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCommandAgent.h" // to import CommandType enum

@interface BleDevice : NSObject

@property (nonatomic, strong) NSUUID *cachedIdentifier;

@property (atomic, copy) NSString *seedNormalHexString;
@property (atomic, copy) NSString *seedAdminHexString;
@property (atomic, copy) NSString *seedTokenHexString;
@property (atomic, copy) NSString *authTokenHexString;
@property (atomic, copy) NSString *authCodeNormalHexString;
@property (atomic, copy) NSString *authCodeAdminHexString;
@property (atomic, copy) NSString *authCodeNormalEncryptedHexString;
@property (atomic, copy) NSString *authCodeAdminEncryptedHexString;
@property (atomic, copy) NSString *commandVailidationTokenHexString;
@property (atomic, copy) NSString *commandHexString;
@property (atomic, copy) NSString *commandHexStringEncrypted;

+ (BleDevice *)sharedDevice;
- (void)clear;
- (void)generateNormalSeedHexString;
- (void)generateAdminSeedHexString;
- (void)generateNormalAuthCodeHexString;
- (void)generateAdminAuthCodeHexString;
- (void)generateNormalAuthCodeEncryptedHexString;
- (void)generateAdminAuthCodeEncryptedHexString;
- (void)generateNormalCommandHexString:(CommandType)commandType withEncryption:(BOOL)withEncryption;
- (void)generateAdminCommandHexString:(CommandType)commandType withEncryption:(BOOL)withEncryption;

@end
