//
//  DDTransactionViewController.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/07.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTransactionViewController : UIViewController

@property (nonatomic, strong) CBPeripheral *ddPeripheral;
@property (nonatomic, strong) NSMutableArray *characteristicModels;

@end
