//
//  UIButton+ActivityIndicator.m
//  MKLocker
//
//  Created by daiki ichikawa on 2016/04/11.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <objc/runtime.h>
#import "UIButton+ActivityIndicator.h"

static NSString * KEY_INDICATOR_UIBUTTON = @"key_indicator_uibutton";

@implementation UIButton (ActivityIndicator)

- (void)startActivityIndicator {
    self.enabled = NO;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat centerX = self.frame.size.width / 2;
    CGFloat centerY = self.frame.size.height / 2;
    activityIndicatorView.center = CGPointMake(centerX, centerY);
    [activityIndicatorView startAnimating];
    [self addSubview:activityIndicatorView];
    
    objc_setAssociatedObject(self, &KEY_INDICATOR_UIBUTTON, activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)stopActivityIndicator {
    self.enabled = YES;
    
    UIActivityIndicatorView *activityIndicatorView = objc_getAssociatedObject(self, &KEY_INDICATOR_UIBUTTON);
    
    if (activityIndicatorView)
    {
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
    }
}

@end
