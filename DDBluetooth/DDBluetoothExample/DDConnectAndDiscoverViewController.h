//
//  DDConnectAndDiscoverViewController.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/28.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

@interface DDConnectAndDiscoverViewController : UIViewController

@property (nonatomic, copy) CBPeripheral *ddPeripheral;

@end
