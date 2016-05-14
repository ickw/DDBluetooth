//
//  DDScanViewController.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/26.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDScanViewController.h"
#import "DDConnectAndDiscoverViewController.h"
#import "UIBarButtonItem+ActivityIndicator.h"
#import "DDScanAgent.h"
#import "DDScanViewCell.h"
#import "DDScannedPeripherals.h"
#import "CBPeripheral+DD.h"
#import "Constants.h"


@interface DDScanViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;
@property (weak, nonatomic) IBOutlet UITableView *peripheralListView;
@property (nonatomic, strong) DDScanAgent *ddScanAgent;
@property (nonatomic, copy) CBPeripheral *selectedPeripheral;

@end

@implementation DDScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.peripheralListView.dataSource = self;
    self.peripheralListView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonTapped:(id)sender {
    if(!self.ddScanAgent) self.ddScanAgent = [[DDScanAgent alloc] init];
    
    [self.scanButton startActivityIndicator];
    
    // Specify service UUID or local name prefix if you needs some filters
    //CBUUID *uuid = [CBUUID UUIDWithString:@"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"];
    //NSString *prefix = @"XXX_";
    
    __weak typeof (self) weakSelf = self;
    [self.ddScanAgent startScanForServices:nil withPrefixes:nil interval:3.f
                                    found:^(CBPeripheral *peripheral) {
                                        // Perform reloadData on main queue to get "cellForRowAtIndexPath" called in main queue
                                        DD_PERFORM_ON_MAIN_THREAD( ^{
                                            [weakSelf.peripheralListView reloadData];
                                        });
                                    }
                                     stop:^{
                                        // update UI in main queue
                                        DD_PERFORM_ON_MAIN_THREAD(^{
                                            [weakSelf.scanButton stopActivityIndicator];
                                        });
                                     }];
}


#pragma mark - Segue methods

- (void)pushTransactionView:(CBPeripheral *)peripheral {
    self.selectedPeripheral = peripheral;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_CONNECTION_VIEW sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_CONNECTION_VIEW])
    {
        DDConnectAndDiscoverViewController *cdVC = [segue destinationViewController];
        cdVC.ddPeripheral = self.selectedPeripheral;
    }
}


#pragma mark - UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DDScanViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SCAN_VIEW];
    NSArray *list = [[DDScannedPeripherals sharedPeripherals] getRssiSortedPeripherals];
    CBPeripheral *p = (CBPeripheral *) [list objectAtIndex:indexPath.row];
    
    if (p.localName) cell.localNameLabel.text = p.localName;
    else cell.localNameLabel.text = @"unknown";
    cell.serviceUUIDLabel.text = [p.serviceUUIDs componentsJoinedByString:@", "];
    cell.identifierLabel.text = p.identifier.UUIDString;
    cell.rssiLabel.text = [NSString stringWithFormat:@"%@", p.foundRSSI];
    cell.iconImageView.image = [UIImage imageNamed:@"cell_image"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DDScannedPeripherals sharedPeripherals] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSArray *list = [[DDScannedPeripherals sharedPeripherals] getRssiSortedPeripherals];
    CBPeripheral *p = [list objectAtIndex:indexPath.row];
    [self pushTransactionView:p];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

@end