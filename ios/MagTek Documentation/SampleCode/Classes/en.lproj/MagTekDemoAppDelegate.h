//
//  MagTekDemoAppDelegate.h
//  MagTekDemo
//
//  Created by MagTek  on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import "MTSCRA.h"



@class MagTekDemoViewController;

@interface MagTekDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MagTekDemoViewController *viewController;
    MTSCRA *mtSCRALib;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MagTekDemoViewController *viewController;
@property (nonatomic, retain) MTSCRA *mtSCRALib;


- (MTSCRA *) getSCRALib;

@end

