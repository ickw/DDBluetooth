//
//  NSMutableArray+c.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/29.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (KeySort)

- (NSArray *)sortByKey:(NSString *)key ascending:(BOOL)ascending;

@end
