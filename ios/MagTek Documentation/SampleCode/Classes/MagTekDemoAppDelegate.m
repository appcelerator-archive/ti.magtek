//
//  MagTekDemoAppDelegate.m
//  MagTekDemo
//
//  Created by MagTek on 11/27/11.
//  Copyright 2011 MagTek. All rights reserved.
//

#import "MTSCRA.h"
#import "MagTekDemoAppDelegate.h"
#import "MagTekDemoViewController.h"

@interface MagTekDemoAppDelegate () <UIApplicationDelegate>

#pragma mark -
#pragma mark NSTimer Selector Method
#pragma mark -

- (void)openDeviceConnection;

@end

@implementation MagTekDemoAppDelegate

#pragma mark -
#pragma mark MTSCRA Library Method
#pragma mark -

- (MTSCRA *)getSCRALib
{
    return [self mtSCRALib];
}

#pragma mark -
#pragma mark Application lifecycle
#pragma mark -

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    self.mtSCRALib = [[MTSCRA alloc] init];
    
    /*
     *
     *  NOTE: TRANS_STATUS_START should be used with caution. CPU intensive tasks done after this events and before
     *        TRANS_STATUS_OK may interfere with reader communication.
     *
     */
    
    [self.mtSCRALib listenForEvents:(TRANS_EVENT_START|TRANS_EVENT_OK|TRANS_EVENT_ERROR)];
    
    /*
     *
     *  NOTE: When calling the View Controller's openDevice method automatically when the application is coming back from a
     *        Background State it is recommended that a 5 second delay be issued to ensure that the device has enough time
     *        to power on.
     *
     */
    
// Uncomment these lines to add a 5 second delay before the automatic openDevice call
//    [mtSCRALib setDeviceType:(MAGTEKIDYNAMO)];
//    [NSTimer scheduledTimerWithTimeInterval:5.0
//                                     target:self
//                                   selector:@selector(openDeviceConnection)
//                                   userInfo:nil
//                                    repeats:NO];
    
    [[self window] addSubview:[[self viewController] view]];
    [[self window] makeKeyAndVisible];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[self viewController] closeDevice];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     *
     *  NOTE: When calling the View Controller's openDevice method automatically when the application is coming back from a
     *        Background State it is recommended that a 5 second delay be issued to ensure that the device has enough time
     *        to power on.
     *
     */
    
// Uncomment these lines to add a 5 second delay before the automatic openDevice call
//    switch([mtSCRALib getDeviceType])
//    {
//        // we check and make sure that we are connecting to an iDynamo
//        case MAGTEKIDYNAMO:
//
//            [NSTimer scheduledTimerWithTimeInterval:5.0
//                                             target:self
//                                           selector:@selector(openDeviceConnection)
//                                           userInfo:nil
//                                            repeats:NO];
//
//            break;
//
//        default:
//
//            break;
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[self viewController] closeDevice];
}

#pragma mark -
#pragma mark NSTimer Selector Method
#pragma mark -

- (void)openDeviceConnection
{
    [[self viewController] openDevice];
}

@end