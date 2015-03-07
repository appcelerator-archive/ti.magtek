//
//  MagTekDemoViewController.h
//  MagTekDemo
//
//  Created by MagTek on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>

#import "MagTekDemoAppDelegate.h"
#import "MediaPlayer/MediaPlayer.h"

@class MTSCRA;

@interface MagTekDemoViewController : UIViewController

#pragma mark -
#pragma mark Helper Methods
#pragma mark -

- (void)openDevice;
- (void)closeDevice;

@end