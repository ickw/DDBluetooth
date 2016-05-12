//
//  BleTokenDatabase.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/11/30.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "BleDevice.h"
#import "SecurityUtil.h"
#import "DDPeripheralConstant.h"
#import "ByteArrayUtil.h"
#import "NSData+Conversion.h"
#import "NSData+AES.h"
#import "AppLocalDatabase.h"

static BleDevice *_sharedDevice;

@implementation BleDevice

+ (BleDevice *)sharedDevice {
    if (!_sharedDevice) {
        _sharedDevice = [BleDevice new];
    }
    return _sharedDevice;
}

- (void)generateNormalSeedHexString {
    NSString *masterKeyString = [AppLocalDatabase sharedDatabase].secretKeyString;
    _seedNormalHexString = [SecurityUtil simpleHash:_seedTokenHexString seed:masterKeyString];
}

- (void)generateAdminSeedHexString {
    NSString *masterKeyString = [AppLocalDatabase sharedDatabase].secretKeyString;
    NSMutableData *seedTokenData = (NSMutableData *)[ByteArrayUtil dataFromHexString:_seedTokenHexString];
    
    Byte topByte = (Byte)1;
    NSMutableData *concatenatedData = [NSMutableData dataWithBytes:&topByte length:sizeof(topByte)];
    [concatenatedData appendData:seedTokenData];
    NSString *concatenatedString = concatenatedData.hexString;
    _seedAdminHexString = [SecurityUtil simpleHash:concatenatedString seed:masterKeyString];
}

- (void)generateNormalAuthCodeHexString {

    _authCodeNormalHexString = [self generateAuthCodeHexString:1 timeout:[AppLocalDatabase sharedDatabase].timeoutSeconds];
}

- (void)generateAdminAuthCodeHexString {

    _authCodeAdminHexString = [self generateAuthCodeHexString:2 timeout:[AppLocalDatabase sharedDatabase].timeoutSeconds];
}

- (NSString *)generateAuthCodeHexString:(unsigned char)usertype timeout:(short)timeout{
    unsigned char userType = usertype;
    NSData *userTypeData = [NSData dataWithBytes:&userType length:sizeof(userType)];
    short timeoutVal = timeout;
    NSData *timeoutData = [ByteArrayUtil shortToBytesData:timeoutVal];
    NSString *topBytesString = [userTypeData.hexString stringByAppendingString:timeoutData.hexString];
    
    
    // ハッシュを生成
    NSString *authCodeHexString = [topBytesString stringByAppendingString:_authTokenHexString];
    
    if (userType == 2)
    {
        authCodeHexString = [SecurityUtil simpleHash:authCodeHexString seed:_seedAdminHexString];
    }
    else if (userType == 1)
    {
        authCodeHexString = [SecurityUtil simpleHash:authCodeHexString seed:_seedNormalHexString];
    }
    else
    {
        NSLog(@"Invalid user type (not 1 nor 2)");
    }
    
    if (authCodeHexString)
    {
        // 再度先頭に認証種別とタイムアウト秒数を付加
        authCodeHexString = [topBytesString stringByAppendingString:authCodeHexString];
    }
    else
    {
        NSLog(@"Warning:: AuthCode is nil");
    }

    return authCodeHexString;
}

- (void)generateNormalAuthCodeEncryptedHexString {
    _authCodeNormalEncryptedHexString = [self generateEncryptedAuthCodeHexString:_authCodeNormalHexString];
}

- (void)generateAdminAuthCodeEncryptedHexString {
    _authCodeAdminEncryptedHexString = [self generateEncryptedAuthCodeHexString:_authCodeAdminHexString];
}

- (NSString *)generateEncryptedAuthCodeHexString:(NSString *)authcodeString {
    NSString *key = _seedNormalHexString;
    NSString *iv = _authTokenHexString;
    NSData *authdata = [ByteArrayUtil dataFromHexString:authcodeString];
    NSData *encrypted = [authdata AES128EncryptWithKey:key iv:iv];
    
    return encrypted.hexString;
}

// 先頭バイト1 / NormalSeed
- (void)generateNormalCommandHexString:(CommandType)commandType withEncryption:(BOOL)withEncryption {
    switch (commandType) {
        case CommandTypeClose:
            [self generateCommandHexString:1 command:[NSNumber numberWithInt:0] withEncryption:withEncryption];
            break;
            
        case CommandTypeOpen:
            [self generateCommandHexString:1 command:[NSNumber numberWithInt:1] withEncryption:withEncryption];
            break;
            
        case CommandTypeOta:
            [self generateCommandHexString:1 command:nil withEncryption:withEncryption];
            break;
            
        default:
            break;
    }
}

// 先頭バイト２ / AdminSeed
- (void)generateAdminCommandHexString:(CommandType)commandType withEncryption:(BOOL)withEncryption {
    switch (commandType) {
        case CommandTypeClose:
            [self generateCommandHexString:2 command:[NSNumber numberWithInt:0] withEncryption:withEncryption];
            break;
            
        case CommandTypeOpen:
            [self generateCommandHexString:2 command:[NSNumber numberWithInt:1] withEncryption:withEncryption];
            break;
            
        case CommandTypeOta:
            [self generateCommandHexString:2 command:nil withEncryption:withEncryption];
            break;
            
        default:
            break;
    }
}

- (void)generateCommandHexString:(UInt8)userType command:(NSNumber * _Nullable)command withEncryption:(BOOL)withEncryption {
    NSData *userTypeData = [NSData dataWithBytes:&userType length:sizeof(userType)];
    NSString *topBytesString;
    
    if (userType == 1)
    {
        if (command != nil)
        {
            UInt8 commandInt = [command unsignedIntegerValue];
            NSData *operationData = [NSData dataWithBytes:&commandInt length:sizeof(commandInt)];
            topBytesString = [userTypeData.hexString stringByAppendingString:operationData.hexString];
        }
        else
        {
             topBytesString = userTypeData.hexString;
        }
        _commandHexString = [NSString stringWithFormat:@"%@%@", topBytesString, _commandVailidationTokenHexString];
        _commandHexString = [SecurityUtil simpleHash:_commandHexString seed:_seedNormalHexString];
    }
    else if (userType == 2)
    {
        if (command != nil)
        {
            UInt8 commandInt = [command unsignedIntegerValue];
            NSData *operationData = [NSData dataWithBytes:&commandInt length:sizeof(commandInt)];
            topBytesString = [userTypeData.hexString stringByAppendingString:operationData.hexString];
        }
        else
        {
             topBytesString = userTypeData.hexString;
        }
        topBytesString = userTypeData.hexString;
        _commandHexString = [NSString stringWithFormat:@"%@%@", topBytesString, _commandVailidationTokenHexString];
        _commandHexString = [SecurityUtil simpleHash:_commandHexString seed:_seedAdminHexString];
    }
    else NSLog(@"Invalid user type");
    
    // 再度先頭に操作内容を示すバイトを付加
    _commandHexString = [topBytesString stringByAppendingString:_commandHexString];
    
    // 暗号化
    if (withEncryption)
    {
        NSString *key = _seedNormalHexString;
        NSString *iv = _commandVailidationTokenHexString;
        NSData *commandData = [ByteArrayUtil dataFromHexString:_commandHexString];
        NSData *encrypted = [commandData AES128EncryptWithKey:key iv:iv];
        _commandHexStringEncrypted = encrypted.hexString;
    }
}

- (void)clear {
    // cachedIndentifierはクリアしない
    _seedNormalHexString = @"";
    _seedAdminHexString = @"";
    _seedTokenHexString = @"";
    _authTokenHexString = @"";
    _authCodeNormalHexString = @"";
    _authCodeAdminHexString = @"";
    _authCodeNormalEncryptedHexString = @"";
    _authCodeAdminEncryptedHexString = @"";
    _commandVailidationTokenHexString = @"";
    _commandHexString = @"";
    _commandHexStringEncrypted = @"";
}

// デバッグ用
//- (void)setCachedIdentifier:(NSUUID *)cachedIdentifier {
//    _cachedIdentifier = cachedIdentifier;
//    NSLog(@"_cachedIdentifier is set to %@", _cachedIdentifier.UUIDString);
//}

@end
