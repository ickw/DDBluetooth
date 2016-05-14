//
//  DDScanViewCell.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/28.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDScanViewCell.h"

@interface DDScanViewCell ()

@end

@implementation DDScanViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted)
    {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
