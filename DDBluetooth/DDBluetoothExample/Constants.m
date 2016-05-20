//
//  Constants.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/09.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString * const CELL_IDENTIFIER_SCAN_VIEW = @"ddcell_scanview";
NSString * const CELL_IDENTIFIER_TRANSACTION_VIEW = @"ddcell_transactionview";

NSString * const SEGUE_IDENTIFIER_CONNECTION_VIEW = @"pushConnectionView";
NSString * const SEGUE_IDENTIFIER_CONNECTION_VIEW_FROM_RETRIEVE_VIEW = @"pushConnectionViewFromRetrieveView";
NSString * const SEGUE_IDENTIFIER_TRANSACTION_VIEW = @"pushTransactionView";

NSString * const NOTIFICATION_DISCONNECTED = @"n_disconnected";

@end
