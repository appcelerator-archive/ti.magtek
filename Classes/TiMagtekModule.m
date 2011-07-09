/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiMagtekModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiBlob.h"

@implementation TiMagtekModule

@synthesize fullbuffer;
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
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	fullbuffer = @"";
	NSLog(@"[INFO] Magtek iDynamo Reader Module loaded",self);
}

-(void)cleanup
{
	if (session!=nil)
	{
		[[session inputStream] setDelegate:nil];
		[[session outputStream] setDelegate:nil];
		
		[[session inputStream] close];
		[[session outputStream] close];
	}
	RELEASE_TO_NIL(session);
	RELEASE_TO_NIL(accessory);
}

-(void)_destroy
{
	[self cleanup];
	
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
	[center removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
	
	// you *must* call the superclass
	[super _destroy];
}

#pragma mark Cleanup 

-(void)dealloc
{
	[self cleanup];
	
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Device

- (BOOL)openSessionForProtocol:(NSString *)protocolString
{
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
							connectedAccessories];
	
    for (EAAccessory *obj in accessories)
    {
		NSLog(@"ACCESSORY INSTALLED = %@",obj);
		
        if ([[obj protocolStrings] containsObject:protocolString])
        {
            accessory = [obj retain];
			NSLog(@"FOUND ACCESSORY = %@",accessory);
            break;
        }
    }
	
    if (accessory)
    {
        session = [[EASession alloc] initWithAccessory:accessory
										   forProtocol:protocolString];
        if (session)
        {
            [[session inputStream] setDelegate:self];
            [[session inputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop]
											 forMode:NSDefaultRunLoopMode];
            [[session inputStream] open];
            //[[session outputStream] setDelegate:self];
           // [[session outputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop]
			//								  forMode:NSDefaultRunLoopMode];
            //[[session outputStream] open];
        }
    }
	
    return session!=nil;
}

- (void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent
{
	
    switch (streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
		{
			NSLog(@"------- NSStreamEventHasBytesAvailable ---------");
			
			//create and init input buffer
			//NSString *tempString;
			uint8_t readBuf[1024];
			memset(readBuf, 0, sizeof(readBuf));
			//read input stream
			NSInteger numberRead = [ (NSInputStream *) theStream read:readBuf maxLength:1024];
			//check for errors
			if (numberRead < 0) 
			{
				//Get the NSError object from the stream
				NSError *error = [ (NSInputStream *) theStream streamError];
				//Log the Error
				NSLog(@"Error -- %@", [error localizedDescription]);
			}
			else if(numberRead > 200)
			{
				@try {
					//NSLog(@"Data = %s", readBuf);
					NSString *buffer = [[NSString alloc] initWithBytes:&readBuf length:numberRead encoding:NSUTF8StringEncoding];
					fullbuffer = [fullbuffer stringByAppendingString:buffer];
				} @catch (NSException *e) {
					fullbuffer = @"";
					[self fireEvent:@"swipeError"];
				}
			}
			if(![theStream hasBytesAvailable]){
				
				NSLog(@"FINALLY");
				int myLength = [fullbuffer length];
				if (myLength > 494) {
					NSLog(@"WOOHOOOO --------------");
					/* NSMutableDictionary *event1 = [NSMutableDictionary dictionary];
					[event1 setValue:fullbuffer forKey:@"fulldata"];
					//[event1 setValue:len forKey:@"bufflength"];
					[self fireEvent:@"beginswipe" withObject:event1]; */
					@try{
					
					NSRange range = [fullbuffer rangeOfString:@"^"];
					if (range.location!=NSNotFound)
					{
						NSString *subbuffer = [fullbuffer substringFromIndex:range.location+1]; 
						range = [subbuffer rangeOfString:@"^"];
						NSString *fullname = [subbuffer substringToIndex:range.location];
						range = [fullname rangeOfString:@"/"];
						if (range.location!=NSNotFound)
						{
							NSString *first = [fullname substringFromIndex:range.location+1];
							NSString *last = [fullname substringToIndex:range.location];
							fullname = [NSString stringWithFormat:@"%@ %@",first,last];
						}
						range = [subbuffer rangeOfString:@";"];
						subbuffer = [subbuffer substringFromIndex:range.location+1];
						range = [subbuffer rangeOfString:@"?"];
						NSArray *tokens = [subbuffer componentsSeparatedByString:@"="];
						if ([tokens count] > 1)
						{
							//NSString *maskedCC = [[tokens objectAtIndex:0] stringByReplacingOccurrencesOfString:@"0" withString:@"X"];
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
							fullbuffer = @"";
						}
					}
					} @catch(NSException *e) {
						NSLog(@"------ **** SWIPE ERROR **** -----");
						fullbuffer = @"";
						[self fireEvent:@"swipeError"];
					}
				}
				
			}
		}
            break;
		
			
		case NSStreamEventOpenCompleted:
			NSLog(@"NSStreamEventOpenCompleted :");
			//NSLog(@"----------- NO MORE BUFFER ----------- %s",_data);
			break;
		
		case NSStreamEventEndEncountered:
			NSLog(@"**** NSStreamEventEndEncountered ****");
			fullbuffer = @"";
			[self fireEvent:@"streamended"];
			break;
 
		case NSStreamEventHasSpaceAvailable:
            break;
		
        default:
            break;
    }
	
}

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
	NSLog(@"DEVICE CONNECTED = %@",note);
	
	[self cleanup];
	
	[self openSessionForProtocol:protocol];
	if (session!=nil)
	{
		accessory = [[[note userInfo] objectForKey:EAAccessoryKey] retain];
		NSDictionary *event = [self accessoryToDictionary:accessory];
		[self fireEvent:@"connected" withObject:event];
	}
}

-(void)deviceDisconnected:(NSNotification*)note
{
	NSLog(@"DEVICE DISCONNECTED = %@",note);
	
	EAAccessory *accessory_ = [[note userInfo] objectForKey:EAAccessoryKey];
	if ([accessory_ isEqual:accessory])
	{
		NSDictionary *event = [self accessoryToDictionary:accessory];
		[self fireEvent:@"disconnected" withObject:event];
		
		RELEASE_TO_NIL(session);
		RELEASE_TO_NIL(accessory);
	}
}

#pragma Public APIs

-(void)registerDevice:(id)args
{
	ENSURE_UI_THREAD(registerDevice,args);
	ENSURE_SINGLE_ARG(args,NSString);
	
	protocol = [args retain];
	[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(deviceConnected:) name:EAAccessoryDidConnectNotification object:nil];
	[center addObserver:self selector:@selector(deviceDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
	
	[self openSessionForProtocol:protocol];
	
	NSLog(@"OPEN SESSION = %@, %@",session,accessory);
	
	if (session!=nil && accessory!=nil)
	{
		NSDictionary *event = [self accessoryToDictionary:accessory];
		[self fireEvent:@"connected" withObject:event];
	}
}

@end
