//
//  optionController.h
//  MTSCRADemo
//
//  Created by Tam Nguyen on 9/17/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "blePairDemo.h"

@protocol optionControllerEvent <NSObject>
@optional
-(void)didSelectConfigCommand:(NSData*)command;

@end
@interface optionController : UITableViewController


@property (nonatomic, strong) NSMutableDictionary* optionDict;

-(BOOL)shouldSendApprove;
-(Byte) getPurchaseOption;
-(Byte) getReportingOption;
@property (nonatomic, weak) id <optionControllerEvent> delegate;
@end
