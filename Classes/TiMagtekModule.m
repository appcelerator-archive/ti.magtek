/**
 * Magtek Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2012 by Appcelerator, Inc.
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

@synthesize mtSCRALib;

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

#pragma mark Public Constants

MAKE_SYSTEM_NUMBER(DEVICE_TYPE_AUDIO_READER, NUMINT(MAGTEKAUDIOREADER));
MAKE_SYSTEM_NUMBER(DEVICE_TYPE_IDYNAMO, NUMINT(MAGTEKIDYNAMO));

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
    self.mtSCRALib = [[MTSCRA alloc] init];
    
    // TRANS_STATUS_START should be used with caution. CPU intensive
    // tasks done after this events and before TRANS_STATUS_OK
    // may interfere with reader communication
    [mtSCRALib listenForEvents:(TRANS_EVENT_START|TRANS_EVENT_OK|TRANS_EVENT_ERROR)]; 
    
	// Register for device notifications
	[self turnDeviceNotificationsOn];
    
	return [super init];
}

-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the module.
    
    if ([mtSCRALib isDeviceOpened]) {
        [mtSCRALib closeDevice];
    }
    [mtSCRALib clearBuffers];
	
	[self turnDeviceNotificationsOff];	
    
	RELEASE_TO_NIL(self.mtSCRALib);
	
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

-(void)turnDeviceNotificationsOn
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(trackDataReady:) name:@"trackDataReadyNotification" object:nil];
    [center addObserver:self selector:@selector(devConnStatusChange) name:@"devConnectionNotification" object:nil];
	
	[[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}

-(void)turnDeviceNotificationsOff
{
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"trackDataReadyNotification" object:nil];
    [center removeObserver:self name:@"devConnectionNotification" object:nil];
}

#pragma mark Notifications

-(void)deviceConnected:(NSNotification*)note
{
	EAAccessory *acc = [[note userInfo] objectForKey:EAAccessoryKey];
    
    NSDictionary *event = [self accessoryToDictionary];
    [self fireEvent:@"connected" withObject:event];
}

-(void)deviceDisconnected:(NSNotification*)note
{
	EAAccessory *acc = [[note userInfo] objectForKey:EAAccessoryKey];
    
    NSDictionary *event = [self accessoryToDictionary];
    [self fireEvent:@"disconnected" withObject:event];
}

-(NSMutableDictionary*)accessoryToDictionary
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[mtSCRALib getDeviceName] forKey:@"deviceName"];
	
	return dict;	
}

-(void)devConnStatusChange
{    
    BOOL isDeviceConnected = [mtSCRALib isDeviceConnected];
    if (isDeviceConnected) {
        if ([self _hasListeners:@"connected"]) {
            NSDictionary *event = [self accessoryToDictionary];
            [self fireEvent:@"connected" withObject:event];
        }        
    } else {
        if ([self _hasListeners:@"disconnected"]) {
            NSDictionary *event = [self accessoryToDictionary];
            [self fireEvent:@"disconnected" withObject:event];
        }
    }
}

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [[notification userInfo] valueForKey:@"status"];
    [self performSelectorOnMainThread:@selector(onDataEvent:) withObject:status waitUntilDone:NO];
}

-(void)onDataEvent:(id)status
{
	switch ([status intValue]) {
        case TRANS_STATUS_OK:
            
            [self displayData];
            
            break;
        case TRANS_STATUS_START:
            
            // This should be used with caution. CPU intensive
            // tasks done after this events and before TRANS_STATUS_OK
            // may interfere with reader communication
            
            break;   
        case TRANS_STATUS_ERROR:
            
            if (mtSCRALib !=NULL) {
                if ([self _hasListeners:@"swipeError"]) {
                    [self fireEvent:@"swipeError"];
                }       
            }
            
            break;
        default:
            break;
    }
    
    
}

-(BOOL)trackReadSuccessful
{
    // Track Decode Status. Consists of three 2-byte hex values
    // representing the decode status for tracks 1, 2, and 3 (respectively from left to right).
    // Values are:
    // 00 = Track OK
    // 01 = Track read Error
    // 02 = Track is Blank 
    NSString *trackDecodeStatus = [mtSCRALib getTrackDecodeStatus];
    NSRange range = [trackDecodeStatus rangeOfString:@"01"];
    return (range.location==NSNotFound);
}

-(void)displayData
{
    if (mtSCRALib !=NULL) {
        if (![self trackReadSuccessful]) {
            if ([self _hasListeners:@"swipeError"]) {
                [self fireEvent:@"swipeError"];
            }
            return;
        }
        
        if ([self _hasListeners:@"swipe"]) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [mtSCRALib getMaskedTracks],            @"maskedTracks", 
                                   [mtSCRALib getTrack1],                  @"track1",
                                   [mtSCRALib getTrack2],                  @"track2",
                                   [mtSCRALib getTrack3],                  @"track3",
                                   [mtSCRALib getTrack1Masked],            @"track1Masked",
                                   [mtSCRALib getTrack2Masked],            @"track2Masked",
                                   [mtSCRALib getTrack3Masked],            @"track3Masked",
                                   [mtSCRALib getMagnePrint],              @"magnePrint",
                                   [mtSCRALib getMagnePrintStatus],        @"magnePrintStatus",
                                   [mtSCRALib getDeviceSerial],            @"deviceSerial",
                                   [mtSCRALib getSessionID],               @"sessionID",
                                   [mtSCRALib getKSN],                     @"KSN",
                                   [mtSCRALib getMagTekDeviceSerial],      @"magTekDeviceSerial",
                                   [mtSCRALib getDeviceName],              @"deviceName",
                                   [mtSCRALib getDeviceCaps],              @"deviceCaps",
                                   [mtSCRALib getTLVVersion],              @"TLVVersion",
                                   [mtSCRALib getDevicePartNumber],        @"devicePartNumber",
                                   [mtSCRALib getCapMSR],                  @"capMSR",
                                   [mtSCRALib getCapTracks],               @"capTracks",
                                   [mtSCRALib getCapMagStripeEncryption],  @"capMagStripeEncryption",
                                   NUMINT([mtSCRALib getCardPANLength]),   @"cardPANLength",
                                   [mtSCRALib getResponseData],            @"responseData",
                                   [mtSCRALib getCardName],                @"cardName",
                                   [mtSCRALib getCardIIN],                 @"cardIIN",
                                   [mtSCRALib getCardLast4],               @"cardLast4",
                                   [mtSCRALib getCardExpDate],             @"cardExpDate",
                                   [mtSCRALib getCardServiceCode],         @"cardServiceCode",
                                   [mtSCRALib getCardStatus],              @"cardStatus",
                                   [mtSCRALib getTrackDecodeStatus],       @"trackDecodeStatus",
                                   [mtSCRALib getResponseType],            @"responseType", 
                                   [mtSCRALib getOperationStatus],         @"operationStatus",
                                   NUMINT([mtSCRALib getBatteryLevel]),    @"batteryLevel",
                                   [mtSCRALib getFirmware],                @"firmware",
                                   nil
                                   ];
            [self fireEvent:@"swipe" withObject:event];
        }

        [mtSCRALib clearBuffers];
    }
}



#pragma mark Public APIs

-(void)registerDevice:(id)args
{
	ENSURE_UI_THREAD(registerDevice,args);
	ENSURE_SINGLE_ARG(args,NSDictionary);
	
    NSString *protocol = [TiUtils stringValue:@"protocol" properties:args def:nil];
    // default to iDynamo if no deviceType set
    int deviceType = [TiUtils intValue:@"deviceType" properties:args def:MAGTEKIDYNAMO];
    
    if (!protocol) {
        NSLog(@"[ERROR] MagtekModule 'protocol' is required when calling registerDevice()");
    }
    
    if (deviceType < MAGTEKAUDIOREADER || deviceType >  MAGTEKIDYNAMO) {
        NSLog(@"[ERROR] MagtekModule invalid 'deviceType' passed to registerDevice(), defaulting to iDynamo");
        deviceType = MAGTEKIDYNAMO;
    }
    
    [mtSCRALib setDeviceType:deviceType];
    [mtSCRALib setDeviceProtocolString:(protocol)]; 
    
    if (![mtSCRALib isDeviceOpened]) {
        [mtSCRALib openDevice];
    }
    
    [self devConnStatusChange];
}

@end
