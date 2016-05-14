//
//  DDTransactionViewCell.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/09.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDTransactionViewCell.h"
#import "DDButton.h"

@implementation DDTransactionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.writeDataTextField.delegate = self;
    self.writeButton.enabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

}

- (void)setEnabled:(BOOL)enabled {    
    if (enabled)
    {
        self.indicationButton.enabled = YES;
        self.readButton.enabled = YES;
        //self.writeButton.enabled = YES;
        self.writeResponseSwitch.enabled = YES;
    }
    else
    {
        self.indicationButton.enabled = NO;
        self.readButton.enabled = NO;
        self.writeButton.enabled = NO;
        self.writeResponseSwitch.enabled = NO;
    }
}

- (IBAction)indicate:(UIButton *)sender {
    [self.delegate indicate:self.index];
}

- (IBAction)read:(UIButton *)sender {
    [self.delegate read:self.index];
}

- (IBAction)write:(UIButton *)sender {
    [self.delegate write:self.index];
}

- (IBAction)writeResponseValueChanged:(UISwitch *)sender {
    self.isWriteWithResponse = sender.on;    
    [self.delegate writeResponseValueChanged:self.isWriteWithResponse index:self.index];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.delegate writeDataValueChanged:self.index dataString:textField.text];
    
    return YES;
}

@end
