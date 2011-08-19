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
@private
	NSMutableString *fullbuffer;
	NSString *protocol;
	EASession *session;
}

-(void)turnConnectionNotificationsOn;
-(void)turnConnectionNotificationsOff;
-(BOOL)openSessionForProtocol:(NSString *)protocolString withAccessory:(EAAccessory*)acc;
-(void)closeSession;
-(void)parseCardData;
-(NSMutableDictionary*)accessoryToDictionary:(EAAccessory*)accessory_;

@end
