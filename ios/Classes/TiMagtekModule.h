/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "MTSCRA.h"
#import "TiModule.h"

@interface TiMagtekModule : TiModule/*<MTSCRAEventDelegate>*/ {
  @private
  MTSCRA *mtSCRALib;
  NSString *protocol;
  UInt32 deviceType;
  BOOL openDeviceOnConnect;
  CGFloat openDelayAfterClose;
  CGFloat openDelayAfterRemoveObserver;
}

@end
