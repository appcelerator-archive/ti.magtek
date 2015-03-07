//
//  MagTekDemoAppDelegate.h
//  MagTekDemo
//
//  Created by MagTek on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@class MTSCRA;
@class MagTekDemoViewController;

@interface MagTekDemoAppDelegate : NSObject

#pragma mark -
#pragma mark MTSCRA Property
#pragma mark -

@property (nonatomic, strong) MTSCRA *mtSCRALib;

#pragma mark -
#pragma mark UIWindow Property
#pragma mark -

@property (nonatomic, strong) IBOutlet UIWindow *window;

#pragma mark -
#pragma mark MagTekDemoViewController Property
#pragma mark -

@property (nonatomic, strong) IBOutlet MagTekDemoViewController *viewController;

#pragma mark -
#pragma mark MTSCRA Library Method
#pragma mark -

- (MTSCRA *)getSCRALib;

@end