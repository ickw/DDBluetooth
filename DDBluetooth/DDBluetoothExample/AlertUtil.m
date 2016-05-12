//
//  AlertUtil.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/11.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "AlertUtil.h"
#import <UIKit/UIKit.h>

@implementation AlertUtil

+ (void)showConfirmationWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertController animated:YES completion:nil];
}

@end
