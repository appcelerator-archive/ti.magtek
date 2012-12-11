//
//  MagTekDemoAppDelegate.m
//  MagTekDemo
//
//  Created by MagTek  on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import "MagTekDemoAppDelegate.h"
#import "MagTekDemoViewController.h"



@implementation MagTekDemoAppDelegate

@synthesize window;
@synthesize viewController, mtSCRALib;

//#define PROTOCOLSTRING @"com.magtek.idynamo"

//int gMagTekReader = MAGTEKIDYNAMO;
//int gMagTekReader = MAGTEKAUDIOREADER;


- (MTSCRA *) getSCRALib
{
    return mtSCRALib;
}


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    self.mtSCRALib = [[MTSCRA alloc] init];
    
    // TRANS_STATUS_START should be used with caution. CPU intensive
    // tasks done after this events and before TRANS_STATUS_OK
    // may interfere with reader communication
    [self.mtSCRALib listenForEvents:(TRANS_EVENT_START|TRANS_EVENT_OK|TRANS_EVENT_ERROR)]; 
    //[self.mtSCRALib listenForEvents:(TRANS_EVENT_OK|TRANS_EVENT_ERROR)]; 

    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [viewController closeDevice]; 
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [viewController closeDevice]; 
}


- (void)dealloc {
    [viewController release];
    [mtSCRALib release];
    [window release];
    [super dealloc];
}


@end
