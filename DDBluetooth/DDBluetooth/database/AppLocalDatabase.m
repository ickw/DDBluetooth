//
//  AppLocalDatabase.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/12/07.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "AppLocalDatabase.h"
#import "DDPeripheralConstant.h"

NSString * const key_masterkey = @"master_key";
NSString * const key_timeoutsec = @"timeout_sec";

static AppLocalDatabase *_sharedDatabase;

@interface AppLocalDatabase() {
    NSUserDefaults *userDefault_;
}

@end

@implementation AppLocalDatabase

+ (AppLocalDatabase *)sharedDatabase {
    if (!_sharedDatabase) {
        _sharedDatabase = [AppLocalDatabase new];
    }
    return _sharedDatabase;
}

- (void)load {
    userDefault_ = [NSUserDefaults standardUserDefaults];
    
    // 既に同じキーが存在する場合は初期値をセットせず、キーが存在しない場合だけ値をセット
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:SECRET_KEY_DEBUG forKey:key_masterkey];
    [dic setObject:[NSNumber numberWithShort:60] forKey:key_timeoutsec];
    [userDefault_ registerDefaults:dic];
    
    // データの読み込み
    _secretKeyString =  [userDefault_ stringForKey:key_masterkey];
    _timeoutSeconds = (short)[userDefault_ integerForKey:key_timeoutsec];
    
    //NSLog(@"secretKey: %@ timeoutsec: %d", _secretKeyString, _timeoutSeconds);
}

- (void)save {
    userDefault_ = [NSUserDefaults standardUserDefaults];
    [userDefault_ setObject:_secretKeyString forKey:key_masterkey];
    [userDefault_ setObject:[NSNumber numberWithShort:_timeoutSeconds] forKey:key_timeoutsec];
    [userDefault_ synchronize]; // 即時反映
}

@end
