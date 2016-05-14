//
//  DDTransactionViewController.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/07.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+DD.h"
#import "DDTransactionViewController.h"
#import "DDTransactionViewCell.h"
#import "DDTransactionAgent.h"
#import "DDTransactionCellModel.h"
#import "Constants.h"
#import "ViewStates.h"
#import "DateTimeUtil.h"
#import "AlertUtil.h"
#import "DDButton.h"

@interface DDTransactionViewController () <UITableViewDataSource, UITableViewDelegate, DDTransactionViewCellDelegate, DDTransactionAgentDelegate>

@property (nonatomic, strong) DDTransactionAgent *ddTransactionAgent;
@property (weak, nonatomic) IBOutlet UITableView *characteristicTableView;
@property (weak, nonatomic) IBOutlet UILabel *notificationCharacteristicLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationTimestampLabel;

@end

@implementation DDTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Title
    self.title = self.ddPeripheral.localName;
    
    // Add observer for disconnection event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect:) name:NOTIFICATION_DISCONNECTED object:nil];
    
    //
    self.characteristicTableView.delegate = self;
    self.characteristicTableView.dataSource = self;
    
    //
    if (self.ddPeripheral)
    {
        self.ddTransactionAgent = [[DDTransactionAgent alloc] initWithPeripheral:self.ddPeripheral];
        self.ddTransactionAgent.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // delete all data
    [self.characteristicModels removeAllObjects];
}

- (void)setCell:(DDTransactionViewCell *)cell model:(DDTransactionCellModel *)model {
    // Set Labels
    cell.uuidLabel.text = model.characteristic.UUID.UUIDString;
    cell.propertyLabel.text = [NSString stringWithFormat:@"properties = %lu", (unsigned long)model.characteristic.properties];
    
    switch (model.indicationStatus) {
        case IndicationStatusDefault:
            cell.indicationStatusLabel.text = @"";
            break;
            
        case IndicationStatusSuccess:
            cell.indicationStatusLabel.text = @"success";
            break;
        
        case IndicationStatusFailed:
            cell.indicationStatusLabel.text = @"failed";
            break;
            
        default:
            break;
    }
    
    switch (model.readStatus) {
        case ReadStatusDefault:
            cell.readStatusLabel.text = @"";
            cell.readValueLabel.text = @"";
            break;
            
        case ReadStatusSuccess:
            cell.readStatusLabel.text = @"success";
            cell.readValueLabel.text = model.readValue;
            break;
            
        case ReadStatusFailed:
            cell.readStatusLabel.text = @"failed";
            cell.readValueLabel.text = @"";
            break;
            
        default:
            break;
    }
    
    switch (model.writeStatus) {
        case WriteStatusDefault:
            cell.writeStatusLabel.text = @"";
            break;
            
        case WriteStatusSuccess:
            cell.writeStatusLabel.text = @"success";
            break;
            
        case WriteStatusFailed:
            cell.writeStatusLabel.text = @"failed";
            break;
            
        default:
            break;
    }
    
    // Set textfield
    cell.writeDataTextField.text = model.writeValue;
    if (model.writeValue.length > 0) cell.writeButton.enabled = YES;
    else cell.writeButton.enabled = NO;
    
    // Set Switch
    cell.writeResponseSwitch.on = model.isWriteWithResponse;
    
    // Set Enabled
    cell.enabled = model.enabled;
    
}


# pragma mark - Observer methods

- (void)disconnect:(NSNotification *)notification {
    // update UI in main queue
    DD_PERFORM_ON_MAIN_THREAD(^{
        for (DDTransactionCellModel *model in self.characteristicModels) {
            [model reset:NO];
            [self.characteristicTableView reloadData];
        }
    });
}


#pragma mark - UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDTransactionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_TRANSACTION_VIEW];
    cell.index = indexPath.row;
    cell.delegate = self;

    
    BOOL isIndexExist = NO;
    BOOL isClassValid = NO;
    
    if (cell.index < [self.characteristicModels count]) isIndexExist = YES;
    if ([[self.characteristicModels objectAtIndex:indexPath.row] isKindOfClass:[DDTransactionCellModel class]]) isClassValid = YES;
    
    if (isIndexExist && isClassValid)
    {
        DDTransactionCellModel *model = [self.characteristicModels objectAtIndex:indexPath.row];
        [self setCell:cell model:model];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.characteristicModels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - DDCharacteristicViewCellDelegate methods

- (void)indicate:(NSInteger)index {
    __block DDTransactionCellModel  *model = [self.characteristicModels objectAtIndex:index];
    model.indicationStatus = IndicationStatusDefault;
    CBCharacteristic *characteristic = model.characteristic;
    [self.characteristicTableView reloadData];
    
    //
    __weak __typeof(self) weakSelf = self;
    [self.ddTransactionAgent indicate:characteristic didIndicate:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {

        if (error)
        {
            // REVIEW: handle error here?
            NSLog(@"Indication Failed %@", error);
            model.indicationStatus = IndicationStatusFailed;
        }
        else
        {
            if (type == DDTransactionAgentCallbackTypeIndication)
            {
                model.indicationStatus = IndicationStatusSuccess;
            }
            // In case notification happens immediately after read/write/indicate operation, callback is also prepared apart from delegate method.
            else if (type == DDTransactionAgentCallbackTypeNotifiedValue)
            {
                NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                model.notifiedValue = value;
                NSLog(@"notified in block %@", value);
            }
            else
            {
                model.indicationStatus = IndicationStatusFailed;
            }
        }
        
        // update UI in main queue
        DD_PERFORM_ON_MAIN_THREAD(^{
            [weakSelf.characteristicTableView reloadData];
        });
    }];
}

- (void)read:(NSInteger)index {
    __block DDTransactionCellModel  *model = [self.characteristicModels objectAtIndex:index];
    model.readStatus = ReadStatusDefault;
    model.readValue = @"";
    CBCharacteristic *characteristic = model.characteristic;
    [self.characteristicTableView reloadData];

    //
    __weak __typeof(self) weakSelf = self;
    [self.ddTransactionAgent read:characteristic didRead:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {
        
        if (error)
        {
            // Review handle error here?
            NSLog(@"Read Failed: %@", error);
            model.readStatus = ReadStatusFailed;
        }
        else
        {
            if (type == DDTransactionAgentCallbackTypeReadValue)
            {
                NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                model.readStatus = ReadStatusSuccess;
                model.readValue = value;
            }
            else
            {
                model.readStatus = ReadStatusFailed;
            }
        }
        
        // update UI in main queue
        DD_PERFORM_ON_MAIN_THREAD(^{
            [weakSelf.characteristicTableView reloadData];
        });
    }];
    
}

- (void)write:(NSInteger)index {
    // Get corresponding model and clear status / value and reset cell
    __block DDTransactionCellModel  *model = [self.characteristicModels objectAtIndex:index];
    model.writeStatus = WriteStatusDefault;
    CBCharacteristic *characteristic = model.characteristic;
    [self.characteristicTableView reloadData];
    
    // Set data based on textfield input
    NSData* data = [model.writeValue dataUsingEncoding:NSUTF8StringEncoding];

    // Block invokes only when "WriteWithResposne"
    BOOL isWriteWithResponse = model.isWriteWithResponse;
    __weak __typeof(self) weakSelf = self;
    [self.ddTransactionAgent writeSplit:characteristic
                                   data:data
                                   withResponse:isWriteWithResponse
                               didWrite:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {
                                   
                                   if (error)
                                   {
                                       // REVIEW: handle error here?
                                       NSLog(@"Write failed %@", error);
                                       model.writeStatus = WriteStatusFailed;
                                   }
                                   else
                                   {
                                       if (type == DDTransactionAgentCallbackTypeWriteValue)
                                       {
                                           model.writeStatus = WriteStatusSuccess;
                                       }
                                       else
                                       {
                                           model.writeStatus = WriteStatusFailed;
                                       }
                                   }
                                   
                                   // update UI in main queue
                                   DD_PERFORM_ON_MAIN_THREAD(^{
                                       [weakSelf.characteristicTableView reloadData];
                                   });
                               }];
}

- (void)writeResponseValueChanged:(BOOL)isWriteWithResponse index:(NSInteger)index {
    DDTransactionCellModel *model = [self.characteristicModels objectAtIndex:index];
    model.isWriteWithResponse = isWriteWithResponse;
}

- (void)writeDataValueChanged:(NSInteger)index dataString:(NSString *)dataString {
    DDTransactionCellModel *model = [self.characteristicModels objectAtIndex:index];
    model.writeValue = dataString;
    [self.characteristicTableView reloadData];
}


#pragma mark - DDTransactionAgentDelegate methods

- (void)didNotifiedValue:(CBCharacteristic *)characteristic value:(NSData *)value error:(NSError *)error {
    
    if (error)
    {
        [AlertUtil showConfirmationWithTitle:@"Error" message:error.localizedDescription];
    }
    else
    {
        NSString *uuid = [NSString stringWithFormat:@"characteristic: %@ ",characteristic.UUID.UUIDString];
        NSString *dataStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSString *value= [@"value: " stringByAppendingString:dataStr];
        NSString *timestamp = [@"timestamp: " stringByAppendingString:[DateTimeUtil getTimeStampInMillis]];
        
        // update UI in main queue
        DD_PERFORM_ON_MAIN_THREAD(^{
            self.notificationCharacteristicLabel.text = uuid;
            self.notificationValueLabel.text = value;
            self.notificationTimestampLabel.text = timestamp;
        });
    }
}

@end
