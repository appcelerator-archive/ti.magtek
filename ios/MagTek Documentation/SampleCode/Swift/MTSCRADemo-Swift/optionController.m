//
//  optionController.m
//  MTSCRADemo
//
//  Created by Tam Nguyen on 9/17/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

#import "optionController.h"

@implementation optionController
{
    NSArray* optionArray;
    NSArray* optionValue;
    
}


- (void)viewDidLoad {
    self.title = @"Options";
    [super viewDidLoad];
    optionArray = @[@"Transaction Type", @"Reporting Option", @"Acquire Response", @"Terminal Configuration Command", @"BLE Demo"];
    optionValue = @[
                        @[@"Purchase", @"Cash Back with Purchase", @"Goods", @"Services", @"International Goods (Purchase)", @" International Cash Advance or Cash Back", @"Domestic Cash Advance or Cash Back"],
                        @[@"Termination Status Only ", @"Major Status Changes ", @"All Status Changes "],
                        @[@"Approve", @"Decline"],
                        @[@"0x0305 - Set Terminal Configuration", @"0x0306 - Get Terminal Configuration", @"0x030E - Commit Configuration"],
                        @[@"Initiate Pairing Demo"]];
    
    _optionDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:0] , @"ApproveSelection", [NSNumber numberWithInteger:0], @"PurchaseOption",[NSNumber numberWithInteger:0], @"ReportingOption", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return optionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (  (NSArray*)optionValue[section]).count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return optionArray[section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    cell.textLabel.text = optionValue[indexPath.section][indexPath.row];
    if (indexPath.section == 2) {
        
        
        if([[_optionDict valueForKey:@"ApproveSelection"] intValue] == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == 1)
    {
        if([[_optionDict valueForKey:@"ReportingOption"] intValue] == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    }
    else if (indexPath.section == 0) {
        if([[_optionDict valueForKey:@"PurchaseOption"] intValue] == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        [_optionDict setValue: [NSNumber numberWithInt:(int)indexPath.row] forKey:@"ApproveSelection"];
    }
    if(indexPath.section == 1)
    {
        [_optionDict setValue: [NSNumber numberWithInt:(int)indexPath.row] forKey:@"ReportingOption"];
    }
    if(indexPath.section == 0)
    {
        [_optionDict setValue: [NSNumber numberWithInt:(int)indexPath.row] forKey:@"PurchaseOption"];
    }
    
    if(indexPath.section == 3)
    {
       if([self.delegate respondsToSelector:@selector(didSelectConfigCommand:)])
       {
           if(indexPath.row == 0)
           {
               Byte tempByte[] = {0x03, 0x05} ;
               [self.delegate didSelectConfigCommand:[NSData dataWithBytes:tempByte length:2]];
           }
           else if(indexPath.row == 1)
           {
               Byte tempByte[] = {0x03, 0x06} ;
               [self.delegate didSelectConfigCommand:[NSData dataWithBytes:tempByte length:2]];
           }
           else
           {
               Byte tempByte[] = {0x03, 0x0e} ;
               [self.delegate didSelectConfigCommand:[NSData dataWithBytes:tempByte length:2]];
           }
       }
    }
    
    if(indexPath.section == 4)
    {
        blePairDemo* bleDemo = [blePairDemo new];
        [self.navigationController pushViewController:bleDemo animated:YES];
    }
    
    [self.tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(Byte)getReportingOption
{
    switch ([[_optionDict valueForKey:@"ReportingOption"] intValue]) {
        case 0:
            return 0x00;
        case 1:
            return 0x01;
        case 2:
            return 0x02;
        default:
            break;
    }
    return 0x00;

}

-(Byte) getPurchaseOption
{
    switch ([[_optionDict valueForKey:@"PurchaseOption"] intValue]) {
        case 0:
            return 0x00;
        case 1:
            return 0x02;
        case 2:
            return 0x04;
        case 3:
            return 0x08;
        case 4:
            return 0x10;
        case 5:
            return 0x40;
        case 6:
            return 0x80;
        default:
            break;
    }
    return 0x00;
}

-(BOOL)shouldSendApprove
{
    if([[_optionDict valueForKey:@"ApproveSelection"] intValue] == 0)
        return true;
    else
        return false;
}
@end
