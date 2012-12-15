/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "MTSCRA.h"

#import <ExternalAccessory/ExternalAccessory.h>


@interface TiMagtekModule : TiModule
{
@private
    MTSCRA *mtSCRALib;
    NSString *protocol;
    int deviceType;
    BOOL openDeviceOnConnect;
    float openDelayAfterClose;
    float openDelayAfterRemoveObserver;
}

@end
