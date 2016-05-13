//
//  UIButton+ActivityIndicator.m
//  MKLocker
//
// Copyright (c) 2015–2016 Daiki Ichikawa ( https://github.com/ickw )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
