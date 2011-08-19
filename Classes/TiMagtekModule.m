/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2011 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */

// See the book "Building IPhone OS Accessories: Use the IPhone Accessories API to Control"
// by Ken Maskrey for great coverage on developing Accessories. Chapter 2 is especiallyl
// relevant to this module.

// *******************************************************************************************
// NOTE: For the MagTek device that Appcelerator has for testing, the protocol
// is 'com.appcelerator.magtek'. Use that value in the sample app when calling registerDevice.
// *******************************************************************************************

#import "TiMagtekModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiBlob.h"

@implementation TiMagtekModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"57754725-fe67-4e3f-90c7-1137ad0a5b13";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.magtek";
}

#pragma mark Lifecycle

-(void)startup
{	
	// This method is called when the module is first loaded
	// you *must* call the superclass
	
	[super startup];
	
	NSLog(@"[INFO] Magtek iDynamo Reader Module loaded",self);
}

-(id)init
{	
	// Allocate memory to hold the data from the reader
	fullbuffer =  [[NSMutableString alloc] init];

	// Register for accessory notifications
	[self turnConnectionNotificationsOn];

	return [super init];
}

-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the module.
	
	[self closeSession];
	[self turnConnectionNotificationsOff];
	
	RELEASE_TO_NIL(fullbuffer);
	RELEASE_TO_NIL(protocol);
	
	[super _destroy];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Device

-(void)turnConnectionNotificationsOn
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(deviceConnected:) name:EAAccessoryDidConnectNotification object:nil];
	[center addObserver:self selector:@selector(deviceDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
	
	[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}

-(void)turnConnectionNotificationsOff
{
	[[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
	[center removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
}

-(void)openStreams
{
	// *** ULTRA-IMPORTANT ***
	// Eventhough we do not use the outputStream, we must open the output stream in order for application
	// suspend / resume to work. Without opening and closing the output stream for the session everything
	// will appear to work, however the session will fail to be restarted when the application returns
	// from being suspended.
	
	[[session inputStream] setDelegate:self];
	[[session inputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[[session inputStream] open];
	
	[[session outputStream] setDelegate:self];
	[[session outputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[[session outputStream] open];
}

-(void)closeStreams
{
	[NSThread sleepForTimeInterval:1.0];
	
	[[session inputStream] close];
	[[session inputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[[session inputStream] setDelegate:nil];
	
	[[session outputStream] close];
	[[session outputStream] removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[[session outputStream] setDelegate:nil];
}

// NOTE: The 'protocol' that is being referred to here is not a normal protocol in the Obj-c sense.
// The protocol is essentially an agreement between the hardware accessory and the application about
// the type of device, the data that it will send/received, etc. The protocol is defined by the
// physical device and is specified by the application calling registerDevice.

-(EAAccessory*)accessoryForProtocol:(NSString*)protocolString
{
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]	connectedAccessories];
	
    for (EAAccessory *obj in accessories) {
        if ([[obj protocolStrings] containsObject:protocolString]) {
			return (obj);
        }
    }	
	
	return nil;
}

-(BOOL)openSessionForProtocol:(NSString *)protocolString withAccessory:(EAAccessory*)acc
{
	// Make sure any existing session is closed
	[self closeSession];
	
    if (acc) {
        session = [[EASession alloc] initWithAccessory:acc forProtocol:protocolString];
        if (session) {
			[self openStreams];

			// Send event notification
			NSDictionary *event = [self accessoryToDictionary:acc];
			[self fireEvent:@"connected" withObject:event];
 		}
    }
		
    return session!=nil;
}

-(void)closeSession
{
	if(session) {
		[self closeStreams];
		
		// The following may generate an error in the console log if the physical device
		// has been removed. This error is not generated when this method is called as a
		// result of the application moving to the background.
		RELEASE_TO_NIL(session);
	}
}

#pragma mark Notifications

-(NSMutableDictionary*)accessoryToDictionary:(EAAccessory*)accessory_
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:NUMINT([accessory_ connectionID]) forKey:@"connectionId"];
	[dict setValue:[accessory_ name] forKey:@"name"];
	[dict setValue:[accessory_ manufacturer] forKey:@"manufacturer"];
	[dict setValue:[accessory_ modelNumber] forKey:@"modelNumber"];
	[dict setValue:[accessory_ name] forKey:@"name"];
	[dict setValue:[accessory_ serialNumber] forKey:@"serialNumber"];
	[dict setValue:[accessory_ hardwareRevision] forKey:@"hardwareRevision"];
	[dict setValue:[accessory_ firmwareRevision] forKey:@"firmwareRevision"];
	
	return dict;	
}

-(void)deviceConnected:(NSNotification*)note
{
	EAAccessory *acc = [[note userInfo] objectForKey:EAAccessoryKey];
		
	// If this accessory is for the specified protocol, then open a session for accessing it.
	// We do not want to blindly call openSessionForProtocol since the attached accessory
	// may be for a different protocol AND in the future when Apple allows multiple devices
	// to be attached we don't want to be closing and re-opening a session whenever a 2nd
	// device is attached.
	
	// Check for protocol being set just in case device connection notifications are received
	// before the app calls registerDevice.
	if ((protocol != nil) && [[acc protocolStrings] containsObject:protocol]) {
		[self openSessionForProtocol:protocol withAccessory:acc];
	}
}

-(void)deviceDisconnected:(NSNotification*)note
{
	EAAccessory *acc = [[note userInfo] objectForKey:EAAccessoryKey];
	
	// If we have a currently opened session and the connection ID for the accessory that
	// is notifying us is the same as the accessory for the session, then close the session.
	// We can't assume that there is only one accessory connection because Apple may allow
	// multiple accessories to be connected in the future -- thus the check for the connectionID
	if ((session != nil) && (session.accessory.connectionID == acc.connectionID)) {
		[self closeSession];
		
		// Send event notification
		NSDictionary *event = [self accessoryToDictionary:acc];
		[self fireEvent:@"disconnected" withObject:event];
	}
}

- (void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent
{
	static BOOL waitForMoreData = NO;
    switch (streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
		
			/* 
			   From the MagTek iDynamo MagneSafe V5 Communication Reference Manual
			 
			   The reader will always send data in blocks of 500 bytes.  If card data is more than 500 bytes, the 
			   reader will send this using 2 blocks of 500 bytes.  If card data is less than or equal to 500 bytes, 
			   the reader will only send 1 block with 500 bytes.  If data is less than 500 bytes in a block, the 
			   reader will use a lower case ‘x’ (0x78) as padding characters.  Note: The longest message always 
			   fits within 2 blocks.
			 
		  	   A Swipe Message is composed of readable ASCII characters.
			*/
			
			NSLog(@"------- NSStreamEventHasBytesAvailable ---------");
			uint8_t readBuf[1024];
			memset(readBuf, 0, sizeof(readBuf));
			//read input stream
			NSInteger numberRead = [ (NSInputStream *) theStream read:readBuf maxLength:1024];
			NSString *tempString = [[NSString alloc] initWithFormat:@"%s",readBuf];
			if(waitForMoreData) {
				[fullbuffer appendString:tempString];
				waitForMoreData = NO;
				[self parseCardData];
			} else if (numberRead >= 493) {
				[fullbuffer setString:@""];
				[fullbuffer appendString:tempString];
				
				if([tempString characterAtIndex:numberRead-1] !='x') {
					//more data is coming so we need to wait for it
					waitForMoreData = YES;
				} else {
					[self parseCardData];
				}
			} else {
				[fullbuffer setString:@""];
				[fullbuffer appendString:tempString];
				[self parseCardData];
			}
			[tempString release];
			break;
			
		case NSStreamEventErrorOccurred:			
			[self closeStreams];
			[fullbuffer setString:@""];
			
			[self fireEvent:@"swipeError"];
			break;

		case NSStreamEventEndEncountered:
			// This notification is received when the stream is closed at the other end of the pipe. 
			// Typically this occurs when the application is moved to the background.
			[fullbuffer setString:@""];
			break;
			
		case NSStreamEventNone:
			break;
			
		case NSStreamEventOpenCompleted:
			break;
		
		case NSStreamEventHasSpaceAvailable:
            break;
		
        default:
            break;
    }
}

-(void)parseCardData
{
	@try{
		NSRange range = [fullbuffer rangeOfString:@"^"];
		if (range.location!=NSNotFound)	{
			NSString *subbuffer = [fullbuffer substringFromIndex:range.location+1]; 
			range = [subbuffer rangeOfString:@"^"];
			NSString *fullname = [subbuffer substringToIndex:range.location];
			range = [fullname rangeOfString:@"/"];
			if (range.location!=NSNotFound)	{
				NSString *first = [fullname substringFromIndex:range.location+1];
				NSString *last = [fullname substringToIndex:range.location];
				fullname = [NSString stringWithFormat:@"%@ %@",first,last];
			}
			range = [subbuffer rangeOfString:@";"];
			
			subbuffer = [subbuffer substringFromIndex:range.location+1];
			
			NSArray *tokens = [subbuffer componentsSeparatedByString:@"="];
			if ([tokens count] > 1)	{
				NSString *ccExpiry = [[tokens objectAtIndex:1] substringToIndex:4];
				ccExpiry = [NSString stringWithFormat:@"%c%c/%c%c",[ccExpiry characterAtIndex:2],[ccExpiry characterAtIndex:3],[ccExpiry characterAtIndex:0],[ccExpiry characterAtIndex:1]];
				NSMutableDictionary *event = [NSMutableDictionary dictionary];
				NSData *data = [fullbuffer dataUsingEncoding:NSUTF8StringEncoding];
				TiBlob *blob = [[[TiBlob alloc] initWithData:data mimetype:@"binary/octet-stream"] autorelease];
				[event setValue:fullname forKey:@"name"];
				[event setValue:[tokens objectAtIndex:0] forKey:@"cardnumber"];
				[event setValue:ccExpiry forKey:@"expiration"];
				[event setValue:blob forKey:@"data"];
				[self fireEvent:@"swipe" withObject:event];
			} else {
				[self fireEvent:@"swipeError"];
			}
		} else {
			[self fireEvent:@"swipeError"];
		}
		
	} @catch(NSException *e) {
		[self fireEvent:@"swipeError"];
	} @finally {
		[fullbuffer setString:@""];
	}
}

#pragma Public APIs

-(void)registerDevice:(id)args
{
	ENSURE_UI_THREAD(registerDevice,args);
	ENSURE_SINGLE_ARG(args,NSString);
	
	// Release protocol in case app is calling this method multiple times
	RELEASE_TO_NIL(protocol);
	protocol = [args copy];

	// Find the accessory with the specified protocol and open the session
	// if already present when the application started
	EAAccessory *acc = [self accessoryForProtocol:protocol];
	if (acc) {
		[self openSessionForProtocol:protocol withAccessory:acc];
	}
}

@end
