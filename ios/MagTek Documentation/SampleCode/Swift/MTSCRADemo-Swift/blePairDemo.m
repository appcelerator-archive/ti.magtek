//
//  blePairDemo.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 11/5/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

#import "blePairDemo.h"

@interface blePairDemo ()
{
    NSMutableArray* bleList;
}
@end

@implementation blePairDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _data = [[NSMutableData alloc] init];
    bleList = [[NSMutableArray alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return bleList.count;
}


/*
 
 ble section
 
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0508E6F8-AD82-898F-F843-E3410CB60103"]] options:nil];
        NSLog(@"Scanning started");
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    

    
    if (_discoveredPeripheral != peripheral) {

        _discoveredPeripheral = peripheral;

        NSLog(@"Connecting to peripheral %@", peripheral);

        if(![bleList containsObject:peripheral])
            [bleList addObject:peripheral];
        [self.tableView reloadData];
        
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
   // [self cleanup];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    if([peripheral services])
    {
        [self peripheral:peripheral didDiscoverServices:nil];
    }
  
    else
    {
        CBUUID	*serviceUUID    = [CBUUID UUIDWithString:@"0508E6F8-AD82-898F-F843-E3410CB60103"];
        
        
        CBUUID  *batteryServiceUUID    = [CBUUID UUIDWithString:@"180F"];
        CBUUID  *deviceInformationUUID = [CBUUID UUIDWithString:@"180A"];
        
        NSArray	*serviceArray = [NSArray arrayWithObjects:serviceUUID, batteryServiceUUID, deviceInformationUUID, nil];
        
        [peripheral discoverServices:serviceArray];
    }
    

}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
 
    
    for (CBService *service in peripheral.services) {
        if([[service UUID] isEqual:[CBUUID UUIDWithString:@"0508E6F8-AD82-898F-F843-E3410CB60103"]])
        {

            
           
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"0508E6F8-AD82-898F-F843-E3410CB60201"]] forService:service];

        }

    }
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        if([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0508E6F8-AD82-898F-F843-E3410CB60201"]])
        {

            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }

    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    CBPeripheral* per = [bleList objectAtIndex:indexPath.row];
    cell.textLabel.text = per.name;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   

        [_centralManager connectPeripheral:bleList[indexPath.row] options:nil];
    
}
@end
