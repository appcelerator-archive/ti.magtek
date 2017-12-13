//
//  blePairDemo.h
//  MTSCRADemo
//
//  Created by Tam Nguyen on 11/5/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface blePairDemo : UITableViewController<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;

@end
