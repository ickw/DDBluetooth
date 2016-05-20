//
//  RetrieveViewController.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/05/20.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "RetrieveViewController.h"
#import "DDStoredPeripherals.h"
#import "DDConnectAgent.h"
#import "CBPeripheral+DD.h"
#import "DDScanViewCell.h"
#import "Constants.h"
#import "DDConnectAndDiscoverViewController.h"

@interface RetrieveViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DDConnectAgent *ddConnectAgent;
@property (nonatomic, strong) NSMutableArray *retrievedPeripherals;
@property (nonatomic, strong) CBPeripheral *selectedPeripheral;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *retrieveButton;
@property (weak, nonatomic) IBOutlet UITableView *peripheralListView;

@end

@implementation RetrieveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ddConnectAgent = [[DDConnectAgent alloc] init];
    
    self.peripheralListView.delegate = self;
    self.peripheralListView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRetrieveButtonPushed:(id)sender {
    [self.retrievedPeripherals removeAllObjects];
    [self.peripheralListView reloadData];
    
    NSArray *identifiers = [DDStoredPeripherals getIdentifiers];
    self.retrievedPeripherals = [[self.ddConnectAgent retrievePeripheralsWithIdentifiers:identifiers] mutableCopy];
    [self.peripheralListView reloadData];
}


#pragma mark - Navigation

- (void)pushTransactionView:(CBPeripheral *)peripheral {
    self.selectedPeripheral = peripheral;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_CONNECTION_VIEW_FROM_RETRIEVE_VIEW sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_CONNECTION_VIEW_FROM_RETRIEVE_VIEW])
    {
        DDConnectAndDiscoverViewController *cdVC = [segue destinationViewController];
        cdVC.ddPeripheral = self.selectedPeripheral;
    }
}


# pragma mark - UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DDScanViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER_SCAN_VIEW];
    NSArray *list = self.retrievedPeripherals;
    CBPeripheral *p = (CBPeripheral *) [list objectAtIndex:indexPath.row];
    
    
    // TODO: should save localName in UserDefaults and use it instead of name ?
    if (p.name) cell.localNameLabel.text = p.name;
    else cell.localNameLabel.text = @"unknown";
    cell.serviceUUIDLabel.text = [p.serviceUUIDs componentsJoinedByString:@", "];
    cell.identifierLabel.text = p.identifier.UUIDString;
    if(p.foundRSSI) cell.rssiLabel.text = [NSString stringWithFormat:@"%@", p.foundRSSI];
    else cell.rssiLabel.text = @"";
    cell.iconImageView.image = [UIImage imageNamed:@"cell_image"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.retrievedPeripherals.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *list = self.retrievedPeripherals;
    CBPeripheral *p = [list objectAtIndex:indexPath.row];
    [self pushTransactionView:p];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CBPeripheral *p = [self.retrievedPeripherals objectAtIndex:indexPath.row];
        NSUUID *uuid = p.identifier;
        [self.ddConnectAgent removeStoredPeripheralWithUUID:uuid];
        [self.retrievedPeripherals removeObjectAtIndex:indexPath.row];
        [self.peripheralListView reloadData];
    }
}

@end
