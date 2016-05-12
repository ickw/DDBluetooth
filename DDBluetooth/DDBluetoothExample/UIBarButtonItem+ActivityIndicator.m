//
//  UIBarButtonItem+ActivityIndicator.m
//  MKLocker
//
//  Created by daiki ichikawa on 2016/04/11.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <objc/runtime.h>
#import "UIBarButtonItem+ActivityIndicator.h"

static NSString * KEY_INDICATOR = @"key_indicator";
static NSString * KEY_BUTTON = @"key_button_button";

@implementation UIBarButtonItem (ActivityIndicator)

- (void)startActivityIndicator {
    self.enabled = NO;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView startAnimating];
    [self setCustomView:activityIndicatorView];
    
    
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithTitle:self.title style:self.style target:self.target action:self.action];
    
    objc_setAssociatedObject(self, &KEY_BUTTON, b, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &KEY_INDICATOR, activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)stopActivityIndicator {
    self.enabled = YES;
    
    UIActivityIndicatorView *activityIndicatorView = objc_getAssociatedObject(self, &KEY_INDICATOR);
    UIBarButtonItem *originalButton = objc_getAssociatedObject(self, &KEY_BUTTON);
    
    if (activityIndicatorView)
    {
        [activityIndicatorView stopAnimating];
        
        self.customView.hidden = NO;
        [self.customView setBackgroundColor:UIColor.redColor];
        [self setCustomView:[originalButton valueForKey:@"view"]];
    }
}

@end