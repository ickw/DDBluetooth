//
//  NSMutableArray+KeySort.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2015/10/29.
//  Copyright © 2015年 Daiki Ichikawa. All rights reserved.
//

#import "NSMutableArray+KeySort.h"

@implementation NSMutableArray (KeySort)

- (NSArray *)sortByKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray*sortedArray = [self sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

@end
