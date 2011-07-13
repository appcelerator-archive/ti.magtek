/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"

#import <ExternalAccessory/ExternalAccessory.h>



@interface TiMagtekModule : TiModule <NSStreamDelegate>
{
	NSMutableString *fullbuffer;
@private
	EASession *session;
	NSString *protocol;
	EAAccessory *accessory;
}

-(void)parseCardData;

@end
