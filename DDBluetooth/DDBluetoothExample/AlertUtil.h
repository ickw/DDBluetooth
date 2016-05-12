//
//  AlertUtil.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/11.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtil : NSObject

+ (void)showConfirmationWithTitle:(NSString *)title message:(NSString *)message;

@end
