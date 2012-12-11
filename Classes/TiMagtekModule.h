/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "MTSCRA.h"

#import <ExternalAccessory/ExternalAccessory.h>


@interface TiMagtekModule : TiModule <NSStreamDelegate>
{
@private
    MTSCRA *mtSCRALib;
}

@property (readwrite, retain) MTSCRA *mtSCRALib;

-(void)turnDeviceNotificationsOn;
-(void)turnDeviceNotificationsOff;
-(NSMutableDictionary*)accessoryToDictionary;
-(void)trackDataReady:(NSNotification *)notification;
-(void)devConnStatusChange;
-(void)onDataEvent:(id)status;
-(void)displayData;

@end
