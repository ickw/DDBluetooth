//
//  DDScanViewCell.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/28.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDScanViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *localNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceUUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end
