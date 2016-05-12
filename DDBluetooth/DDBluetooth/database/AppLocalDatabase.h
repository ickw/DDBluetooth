//
//  AppLocalDatabase.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/12/07.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppLocalDatabase : NSObject

@property (atomic, copy) NSString *secretKeyString;
@property (nonatomic) short timeoutSeconds;

+ (AppLocalDatabase *)sharedDatabase;
- (void)load;
- (void)save;

@end
