//
//  DDButton.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/28.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDButton.h"

@implementation DDButton

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (UIColor *)borderColor {
    UIColor *color = [UIColor colorWithCGColor:self.layer.borderColor];
    return color;
}

@end
