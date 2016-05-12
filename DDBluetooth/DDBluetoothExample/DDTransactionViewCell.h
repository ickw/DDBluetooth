//
//  DDTransactionViewCell.h
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/09.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDButton;


@protocol DDTransactionViewCellDelegate

@required
- (void)indicate:(NSInteger)index;
- (void)read:(NSInteger)index;
- (void)write:(NSInteger)index;
- (void)writeResponseValueChanged:(BOOL)isWriteWithResponse index:(NSInteger)index;
- (void)writeDataValueChanged:(NSInteger)index dataString:(NSString *)dataString;
@end

@interface DDTransactionViewCell : UITableViewCell  <UITextFieldDelegate>

@property (nonatomic) BOOL enabled;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL isWriteWithResponse;
@property (nonatomic, weak) id <DDTransactionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet DDButton *indicationButton;
@property (weak, nonatomic) IBOutlet DDButton *readButton;
@property (weak, nonatomic) IBOutlet DDButton *writeButton;
@property (weak, nonatomic) IBOutlet UISwitch *writeResponseSwitch;
@property (weak, nonatomic) IBOutlet UILabel *indicationStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *readStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *readValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *writeStatusLabel;
@property (weak, nonatomic) IBOutlet UITextField *writeDataTextField;


@end
