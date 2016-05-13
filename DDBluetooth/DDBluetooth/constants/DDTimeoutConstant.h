//
//  DDTimeoutConstant.h
//  DDBluetooth
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

#import <Foundation/Foundation.h>

/**
 Define timeout constants
 */
@interface DDTimeoutConstant : NSObject

/**
 Scan duration in sec.
 */
extern NSTimeInterval const kTimeoutIntervalScan;

/**
 Connection timeout in sec,
 */
extern NSTimeInterval const kTimeoutIntervalConnect;

/**
 Disconnection timeout in sec.
 */
extern NSTimeInterval const kTimeoutIntervalDisconnect;

/**
 Discover characteristics timeout in sec.
 */
extern NSTimeInterval const kTimeoutIntervalDiscoverCharacteristic;

/**
 Timeout for read, write, and inidication in sec.
 */
extern NSTimeInterval const kTimeoutIntervalTransaction;

@end
