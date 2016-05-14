//
//  DDConnectAndDiscoverViewController.m
//  DDBluetooth
//
//  Created by daiki ichikawa on 2016/04/28.
//  Copyright © 2016年 Daiki Ichikawa. All rights reserved.
//

#import "DDConnectAndDiscoverViewController.h"
#import "DDTransactionViewController.h"
#import "CBPeripheral+DD.h"
#import "DDConnectAgent.h"
#import "DDTransactionAgent.h"
#import "DDButton.h"
#import "UIButton+ActivityIndicator.h"
#import "NSData+Conversion.h"
#import "DDTransactionCellModel.h"
#import "AlertUtil.h"
#import "Constants.h"
#import "ViewStates.h"

@interface DDConnectAndDiscoverViewController ()

@property (nonatomic, strong) DDConnectAgent *ddConnectAgent;
@property (nonatomic, strong) DDTransactionAgent *ddTransactionAgent;
@property (nonatomic, strong) NSMutableArray *characteristicModels;
@property (weak, nonatomic) IBOutlet DDButton *connectAndRetryButton;
@property (weak, nonatomic) IBOutlet DDButton *discoverButton;
@property (weak, nonatomic) IBOutlet DDButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UILabel *retryCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionTimeLabel;

@end

@implementation DDConnectAndDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set Navbar title
    if (self.ddPeripheral.localName) self.title = self.ddPeripheral.localName;
    else self.title = @"unknown";
    [self setViewState:DDViewStateDisconnected];
    
    //
    self.ddConnectAgent = [[DDConnectAgent alloc] init];
    if (self.ddPeripheral)
    {
        self.ddTransactionAgent = [[DDTransactionAgent alloc] initWithPeripheral:self.ddPeripheral];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    // disconnect when move back to scan view
    if (![parent isEqual:self.parentViewController])
    {
        [self.ddConnectAgent disconnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {
            NSLog(@"disconnect callback: %@ %@", peripheral, error);
        }];
        self.ddConnectAgent = nil;
    }
}

- (void)setViewState:(DDViewState)state {
    __weak __typeof (self) weakSelf = self;
    DD_PERFORM_ON_MAIN_THREAD((^{
        switch (state)
        {
            case DDViewStateConnected:
            {
                // buttons
                weakSelf.connectAndRetryButton.enabled = NO;
                weakSelf.discoverButton.enabled = YES;
                weakSelf.disconnectButton.enabled = YES;
                
                // labels
                NSString *retryCount = [NSString stringWithFormat:@"%d", weakSelf.ddConnectAgent.connectionTrialCount];
                NSString *time = [NSString stringWithFormat:@"%f", weakSelf.ddConnectAgent.connectionTrialElapsedTime];
                weakSelf.retryCountLabel.text = [@"retry count: " stringByAppendingString:retryCount];
                weakSelf.connectionTimeLabel.text = [@"elapsed: " stringByAppendingString:time];
                break;
            }
                
            case DDViewStateDisconnected:
                // buttons
                weakSelf.connectAndRetryButton.enabled = YES;
                weakSelf.discoverButton.enabled = NO;
                weakSelf.disconnectButton.enabled = NO;
                
                // labels
                weakSelf.retryCountLabel.text = @"";
                weakSelf.connectionTimeLabel.text = @"";
                break;
                
            case DDViewStateDiscovered:
                weakSelf.connectAndRetryButton.enabled = NO;
                weakSelf.discoverButton.enabled = YES;
                weakSelf.disconnectButton.enabled = YES;
                break;
                
            default:
                break;
        }
    }));
}

- (IBAction)connectWithRetry:(UIButton *)sender {
    // Show activitiy indicator
    [self.connectAndRetryButton startActivityIndicator];
    
    //
    __weak __typeof (self) weakSelf = self;
    [self.ddConnectAgent startConnectionWithRetry:self.ddPeripheral
                                withMaxRetryCount:10
                                         interval:2.f
                                       didConnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {

        DD_PERFORM_ON_MAIN_THREAD(^{
            [weakSelf.connectAndRetryButton stopActivityIndicator];
        });
                                           
        if (error)
        {
            // Notify disconnected event
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISCONNECTED object:self userInfo:nil];
            
            // update UI in main queue
            DD_PERFORM_ON_MAIN_THREAD(^{
                [weakSelf setViewState:DDViewStateDisconnected];
                [AlertUtil showConfirmationWithTitle:@"Error" message:error.localizedDescription];
            });
        }
        else
        {
            if (status == ConnectionStatusConnected)
            {
                [weakSelf setViewState:DDViewStateConnected];
            }
            else if (status == ConnectionStatusDisconnected)
            {
                [weakSelf setViewState:DDViewStateDisconnected];
            }
        }
    }];
}

- (IBAction)discover:(UIButton *)sender {
    //
    [self.discoverButton startActivityIndicator];
    
    //
    __weak typeof (self) weakSelf = self;
    [self.ddConnectAgent discover:self.ddPeripheral didDiscover:^(NSArray * _Nullable characteristics, NSError * _Nullable error) {
        
        // update UI in main queue
        DD_PERFORM_ON_MAIN_THREAD(^{
            [weakSelf.discoverButton stopActivityIndicator];
        });
        
        if (error)
        {
            // update UI in main queue
            DD_PERFORM_ON_MAIN_THREAD(^{
                [AlertUtil showConfirmationWithTitle:@"Error" message:error.localizedDescription];
            });
        }
        else
        {
            [weakSelf setViewState:DDViewStateDiscovered];
            
            // Create model for tableview
            if (!weakSelf.characteristicModels) weakSelf.characteristicModels = [NSMutableArray new];
            for (CBCharacteristic *c in characteristics) {
                DDTransactionCellModel *model = [[DDTransactionCellModel alloc] initWithEnabled:YES];
                model.characteristic = c;
                [weakSelf.characteristicModels addObject:model];
            }
            
            // update UI in main queue
            DD_PERFORM_ON_MAIN_THREAD(^{
                [weakSelf performSegueWithIdentifier:SEGUE_IDENTIFIER_TRANSACTION_VIEW sender:self];
            });
        }
    }];
}

- (IBAction)disconnect:(UIButton *)sender {
    //
    [self.disconnectButton startActivityIndicator];
    
    //
    __weak __typeof (self) weakSelf = self;
    [self.ddConnectAgent disconnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {
        
        // update UI in main queue
        DD_PERFORM_ON_MAIN_THREAD(^{
            [weakSelf.disconnectButton stopActivityIndicator];
        });
        
        if (error)
        {
            // update UI in main queue
            DD_PERFORM_ON_MAIN_THREAD(^{
                [AlertUtil showConfirmationWithTitle:@"Error" message:error.localizedDescription];
            });
        }
        else
        {
            [weakSelf setViewState:DDViewStateDisconnected];
        }
    }];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_TRANSACTION_VIEW])
    {
        DDTransactionViewController *tsVC = [segue destinationViewController];
        tsVC.characteristicModels = self.characteristicModels;
        tsVC.ddPeripheral = self.ddPeripheral;
    }
}

@end
